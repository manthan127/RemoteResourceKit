//
//  File.swift
//  
//
//  Created by Home on 15/12/25.
//

import Foundation

public protocol DownloadGroup {
    var baseURL: URL {get}
    var resumeDataURL: URL? {get}
    
    associatedtype F: FileRepresentative
    var body: F {get}
}

// TODO: - cheak if it's folder's url
extension DownloadGroup {
    var resumeDataURL: URL? { nil }
}

public extension DownloadGroup {
    func download() async throws {
        try await body.download(at: baseURL)
    }
    func cancel() {
        body.cancel(resumeDataURL: resumeDataURL)
    }
}
