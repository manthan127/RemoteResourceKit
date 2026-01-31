//
//  File.swift
//  
//
//  Created by Home on 30/01/26.
//

import Foundation

// URLSessionTaskDelegate : URLSessionDelegate
final class DownloadDelegate: NSObject {
    let continuation: CheckedContinuation<URL, Error>
    let destinations: [FileDestination]
    
    init(continuation: CheckedContinuation<URL, Error>, destinations: [FileDestination]) {
        self.continuation = continuation
        self.destinations = destinations
    }
    
//    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: (any Error)?) {
//        if let error {
//            continuation.resume(throwing: error)
//        }
//    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        if let error {
            continuation.resume(throwing: error)
        }
    }
}

extension DownloadDelegate: URLSessionDataDelegate {
    
}

extension DownloadDelegate: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        for destination in destinations {
            do {
                // MARK: - can optimize my moving the file instead of copying the file(only makes visible difference in the case of big files) // let the user decide what to do `move` or `copy`
                try destination.copy(location)
                Task {
                    await destination.fileRepresentative.downloadComplete?(destination.destinationURL)
                }
            } catch {
                // TODO: - return all the collected errors and warnings(download is success for some reason can not move files)
                Task {
                    await destination.fileRepresentative.errorHandler?(error)
                }
            }
        }
        
        //        continuation.resume(returning: location)
    }
    
    func urlSession(
        _ session: URLSession, downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64
    ) {
        Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
    }
}
