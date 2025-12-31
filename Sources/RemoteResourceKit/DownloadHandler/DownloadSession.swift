//
//  File 2.swift
//  
//
//  Created by Home on 19/12/25.
//

import Foundation

// TODO: - make option for parallel calling or serial Calling
final public class DownloadSession: NSObject {
    private var session: URLSession
    
    private var delegate: (any URLSessionTaskDelegate)?
    
    private let registry = APIRegistry()
    private let resumeDataManager: ResumeDataHandler?
    
    init(resumeDataURL url: URL? = nil, session: URLSession = .shared) {
        self.session = session
        self.resumeDataManager = url.map { ResumeDataHandler(url: $0) }
    }
    
    @available(iOS 15.0, *)
    init(resumeDataURL url: URL? = nil, delegate: any URLSessionTaskDelegate) {
        self.session = .shared
        self.delegate = delegate
        self.resumeDataManager = url.map { ResumeDataHandler(url: $0) }
    }
    
    // TODO: - return all the collected errors and warnings
    func download(_ downloadGroup: any DownloadGroup, parallel: Bool = true) async {
        let mapping = downloadGroup.makeMapping()
        if parallel {
            await downloadParallel(map: mapping)
        } else {
            await downloadSerial(map: mapping)
        }
    }
    
    func cancel(resumeDataURL: URL? = nil) async {
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
        if let ind = destinations.firstIndex(where: { FileManager.default.fileExists(at: $0.url) }) {
            let url = destinations[ind].url
            for destination in destinations where !FileManager.default.fileExists(at: destination.url) {
                do {
                    try copy(url, to: destination.url)
                } catch {
                    // TODO: - return all the collected errors and warings
                }
            }
            return
        }
        
        let resumeData = await resumeDataManager?.data(urlRequest: urlRequest)
       
        try await withCheckedThrowingContinuation { cont in
            let completionHandler: @Sendable (URL?, URLResponse?, (any Error)?) -> Void = { url, res, err in
                self.apiResponse(url: url, response: res, err: err, destinations: destinations, cont: cont)
            }
            
            let task: URLSessionDownloadTask
            
            if let resumeData {
                task = session.downloadTask(withResumeData: resumeData, completionHandler: completionHandler)
            } else {
                task = session.downloadTask(with: urlRequest, completionHandler: completionHandler)
            }
            
            if #available(iOS 15.0, *), let delegate {
                task.delegate = delegate
            }
            
            Task {
                await registry.create(remoteURL: urlRequest, task: task)
                
                task.resume()
            }
        }
    }
    
    func apiResponse(
        url: URL?, response: URLResponse?, err: Error?,
        destinations: [FileDestination],
        cont: CheckedContinuation<Void, Error>
    ) {
        if let err {
            cont.resume(throwing: err)
            return
        }
        
        if let url {
            for destination in destinations {
                do {
                    // MARK: - can optimize my moving the file instead of copying the file(only makes difference in the case of big files) // let the user decide what to do `move` or `copy`
                    try self.copy(url, to: destination.url)
                } catch {
                    // TODO: - return all the collected errors and warnings(download is success for some reason can not move files)
                }
            }
            cont.resume(returning: ())
            return
        }
        
        // MARK: - unknown state // ideally this will not be triggered
        cont.resume(throwing: URLError.init(.badServerResponse))
    }
    
    func copy(_ tempURL: URL, to destination: URL) throws {
        try FileManager.default.createDirectory(
            at: destination.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        
        if FileManager.default.fileExists(at: destination) {
            try FileManager.default.removeItem(at: destination)
        }
        
        try FileManager.default.copyItem(at: tempURL, to: destination)
    }
}

extension FileManager {
    func fileExists(at path: URL) -> Bool {
        if #available(iOS 16.0, *) {
            fileExists(atPath: path.path(percentEncoded: false))
        } else {
            fileExists(atPath: path.path)
        }
    }
}
