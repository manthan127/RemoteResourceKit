//
//  File 2.swift
//  
//
//  Created by Home on 19/12/25.
//

import Foundation

final public class DownloadSession: NSObject {
    private let session: URLSession = .shared
    
    private let registry = APIRegistry()
    private let resumeDataManager: ResumeDataHandler?
    public weak var delegate: DownloadSessionDelegate?
    
    public init(resumeDataURL url: URL? = nil) {
        self.resumeDataManager = url.map { ResumeDataHandler(url: $0) }
    }
    
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
            if let resumeDataManager, let data = await task.cancelWithResumeData() {
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
        for (key, destinations) in map {
            await downloadAndHandleErrors(req: key, destinations: destinations)
        }
    }
    
    func downloadParallel(map: [URLRequest: [FileDestination]]) async {
        await withTaskGroup(of: Void.self) { group in
            for (key, destinations) in map {
                group.addTask {
                    await self.downloadAndHandleErrors(req: key, destinations: destinations)
                }
            }
        }
    }
    
    func downloadAndHandleErrors(req: URLRequest, destinations: [FileDestination]) async {
        do {
            try await self.download(urlRequest: req, destinations: destinations)
        } catch {
            for destination in destinations {
                await destination.fileRepresentative.errorHandler?(error)
            }
        }
    }
    
    func download(urlRequest: URLRequest, destinations: [FileDestination]) async throws {
        // MARK: - might need to handle for each element  individually because of some property like always download in future
        if let destination = destinations.first(where: { FileManager.default.fileExists(at: $0.destinationURL) }) {
            fileAlreadyExists(at: destination.destinationURL, destinations: destinations)
            return
        }
        
        let resumeData = await resumeDataManager?.data(urlRequest: urlRequest)
       
        try await withCheckedThrowingContinuation { continuation in
            let task: URLSessionTask = if let resumeData {
                session.downloadTask(withResumeData: resumeData)
            } else {
                session.dataTask(with: urlRequest)
            }
            task.delegate = DownloadDelegate(continuation: continuation, destinations: destinations, delegate: delegate)
            Task {
                await registry.create(remoteURL: urlRequest, task: task)
                task.resume()
            }
        }
    }
    
    func fileAlreadyExists(at url: URL, destinations: [FileDestination]) {
        for destination in destinations {
            if FileManager.default.fileExists(at: destination.destinationURL) {
                continue
            }
            destination.copyAndSendMessage(url)
        }
    }
}
