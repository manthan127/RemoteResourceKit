//
//  File 2.swift
//  
//
//  Created by Home on 19/12/25.
//

import Foundation

final public class DownloadSession: NSObject {
    private var session: URLSession
    
    private let registry = APIRegistry()
    private let resumeDataManager: ResumeDataHandler?
    
    public init(resumeDataURL url: URL? = nil, session: URLSession = .shared) {
        self.session = session
        self.resumeDataManager = url.map { ResumeDataHandler(url: $0) }
    }
    
    // TODO: - return all the collected errors and warnings
    public func download(_ downloadGroup: DownloadGroup, parallel: Bool = true) async {
        let mapping = downloadGroup.makeMapping()
        if parallel {
            await downloadParallel(map: mapping)
        } else {
            await downloadSerial(map: mapping)
        }
    }
    
    public func cancel(resumeDataURL: URL? = nil) async {
        let resumeDataManager = resumeDataURL.map { ResumeDataHandler(url: $0) } ?? self.resumeDataManager
        
        let reg = await registry.registry
        for (urlReq, task) in reg {
            if let resumeDataManager, let data = await task.cancelByProducingResumeData() {
                do {
                    try await resumeDataManager.save(urlRequest: urlReq, data: data)
                } catch {
                    // TODO: - return all the collected errors and warnings
                }
            } else {
                task.cancel()
            }
        }
        
//        await registry.clear()
    }
}

private extension DownloadSession {
    // TODO: - (user might even call cancel even before loop is finished)
    func downloadSerial(map: [URLRequest: [FileDestination]]) async {
        for (key, val) in map {
            do {
                try await self.download(urlRequest: key, destinations: val)
            } catch {
                // TODO: - return all the collected errors and warnings
            }
        }
    }
    
    func downloadParallel(map: [URLRequest: [FileDestination]]) async {
        await withTaskGroup(of: Void.self) { group in
            for (key, val) in map {
                group.addTask {
                    do {
                        try await self.download(urlRequest: key, destinations: val)
                    } catch {
                        // TODO: - return all the collected errors and warnings
                    }
                }
            }
        }
    }
    
    func download(urlRequest: URLRequest, destinations: [FileDestination]) async throws {
        // MARK: - might need to handle for each element  individually because of some property like always download in future
        if let ind = destinations.firstIndex(where: { FileManager.default.fileExists(at: $0.folderURL) }) {
            let url = destinations[ind].folderURL
            for destination in destinations where !FileManager.default.fileExists(at: destination.folderURL) {
                do {
                    try destination.copy(url)
                } catch {
                    // TODO: - return all the collected errors and warings
                    Task {
                        await destination.fileRepresentative.errorHandler?(error)
                    }
                }
            }
            return
        }
        
        let resumeData = await resumeDataManager?.data(urlRequest: urlRequest)
       
        let url = try await withCheckedThrowingContinuation { continuation in
            let task: URLSessionDownloadTask = if let resumeData {
                session.downloadTask(withResumeData: resumeData)
            } else {
                session.downloadTask(with: urlRequest)
            }
            task.delegate = DownloadDelegate(continuation: continuation, destinations: destinations)
            Task {
                await registry.create(remoteURL: urlRequest, task: task)
                
                task.resume()
            }
        }
    }
}

extension FileManager {
    func fileExists(at path: URL) -> Bool {
        if #available(iOS 16.0, *) {
            fileExists(atPath: path.path(percentEncoded: true))
        } else {
            fileExists(atPath: path.path)
        }
    }
}
