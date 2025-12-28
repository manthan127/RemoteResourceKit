//
//  File 2.swift
//  
//
//  Created by Home on 19/12/25.
//

import Foundation

// TODO: - make option for parallel calling or serial Calling
final class DownloadHandler: NSObject {
    private lazy var session: URLSession = { URLSession.shared }()
    
    let registry = APIRegistry()
    let resumeDataManager: ResumeDataHandler?
    
    init(resumeDataURL url: URL?) {
        self.resumeDataManager = url.map { ResumeDataHandler(url: $0) }
    }
    
    // TODO: - (user might even call cancel even before loop is finished)
    func download(map: [URL: [FileDestination]]) async {
        for (key, val) in map {
            do {
                try await download(remoteURL: key, destinations: val)
            } catch {
                // TODO: - return all the collected errors and warnings
            }
        }
    }
    
    func cancel() async {
        let reg = await registry.registry
        for (url, task) in reg {
            if let resumeDataManager, let data = await task.cancelByProducingResumeData() {
                do {
                    try await resumeDataManager.save(remoteURL: url, data: data)
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

private extension DownloadHandler {
    func download(remoteURL: URL, destinations: [FileDestination]) async throws {
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
        
        let resumeData = await resumeDataManager?.data(remoteURL: remoteURL)
       
        try await withCheckedThrowingContinuation { cont in
            let completionHandler: @Sendable (URL?, URLResponse?, (any Error)?) -> Void = { url, res, err in
                self.apiResponse(url: url, response: res, err: err, destinations: destinations, cont: cont)
            }
            
            let task: URLSessionDownloadTask
            
            if let resumeData {
                task = session.downloadTask(withResumeData: resumeData, completionHandler: completionHandler)
            } else {
                task = session.downloadTask(with: remoteURL, completionHandler: completionHandler)
            }
            
            Task {
                await registry.create(
                    remoteURL: remoteURL,
                    task: task
                )
                
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
