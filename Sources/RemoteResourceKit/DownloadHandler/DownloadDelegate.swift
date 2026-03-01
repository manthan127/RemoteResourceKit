//
//  File.swift
//  
//
//  Created by Home on 30/01/26.
//

import Foundation

// MARK: - need to conform to AnyObject for making variable weak, can not use conform this protocol to a struct or actor
public protocol DownloadSessionDelegate: AnyObject {
    //TODO: - need to use both `completion handler method` and `async method` only using async one right now for testing
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse) async throws -> ResponseDisposition
    
//    @objc optional func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping @Sendable (ResponseDisposition) -> Void)
}

public enum ResponseDisposition {
    case allow
    case cancel
}

// URLSessionTaskDelegate : URLSessionDelegate
final class DownloadDelegate: NSObject {
    let continuation: CheckedContinuation<Void, Error>
    let destinations: [FileDestination]
    let delegate: DownloadSessionDelegate?
    
    var customError: Error?
    
    init(continuation: CheckedContinuation<Void, Error>, destinations: [FileDestination], delegate: DownloadSessionDelegate?) {
        self.continuation = continuation
        self.destinations = destinations
        self.delegate = delegate
    }
    
//    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: (any Error)?) {
//        if let error {
//            continuation.resume(throwing: error)
//        }
//    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        if let error = customError ?? error {
            continuation.resume(throwing: error)
        }
    }
}

extension DownloadDelegate: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {}

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse) async -> URLSession.ResponseDisposition {
        do {
            let responseDisposition = try await delegate?.urlSession(session, dataTask: dataTask, didReceive: response)
            
            switch responseDisposition {
            case .cancel:
                return .cancel
            case .allow, nil:
                return .becomeDownload
            }
        } catch {
            customError = error
            return .cancel
        }
    }
}

extension DownloadDelegate: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // MARK: - can optimize my moving the file instead of copying the file(only makes visible difference in the case of big files) // let the user decide what to do `move` or `copy`
        for destination in destinations {
            destination.copyAndSendMessage(location)
        }
        continuation.resume(returning: ())
    }
    
    func urlSession(
        _ session: URLSession, downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64
    ) {
        for destination in destinations {
            destination.fileRepresentative.downloadProgressDataHandler?(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite)
        }
        
        guard totalBytesExpectedToWrite > 0 else { return }
        
        let p = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        for destination in destinations {
            destination.fileRepresentative.downloadProgressHandler?(p)
        }
    }
}


//https://download.blender.org/demo/2_big_buck_bunny_v2.pdf
