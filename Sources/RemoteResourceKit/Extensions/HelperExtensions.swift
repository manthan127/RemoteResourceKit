//
//  File.swift
//  
//
//  Created by Home on 01/02/26.
//

import Foundation

extension FileManager {
    func fileExists(at path: URL) -> Bool {
        if #available(iOS 16.0, *) {
            fileExists(atPath: path.path(percentEncoded: true))
        } else {
            fileExists(atPath: path.path)
        }
    }
}

extension URLSessionTask {
    func cancelWithResumeData() async -> Data? {
        await (self as? URLSessionDownloadTask)?.cancelByProducingResumeData()
    }
}
