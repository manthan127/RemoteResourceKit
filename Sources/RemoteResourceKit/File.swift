//
//  File.swift
//
//
//  Created by Home on 15/12/25.
//

import Foundation

public struct Folder: FileRepresentative {
    public let name: String
    @ResourceBuilder var resources: ()-> [any FileRepresentative]
    
    // TODO: - Try collecting errors and throwing them at once instead of failing once any one fails
    // TODO: - give option for parallel fetching
    public func download(at path: URL) async throws {
        let url = createURL(path: path, isDirectory: true)
        for r in resources() {
            try await r.download(at: url)
        }
    }
    
    public func cancel(resumeDataURL: URL?) {
        for r in resources() {
            r.cancel(resumeDataURL: resumeDataURL)
        }
    }
}


public struct File: FileResource {
    public let name: String
    public let remoteURL: URL
}
