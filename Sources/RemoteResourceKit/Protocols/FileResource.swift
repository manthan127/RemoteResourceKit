//
//  File.swift
//
//
//  Created by Home on 15/12/25.
//

import Foundation

public protocol FileResource: FileRepresentative {
    var remoteURL: URL {get}
}

public extension FileResource {
    func download(at path: URL) async throws {
        let url = createURL(path: path, isDirectory: false)
        let (data, res) = try await URLSession.shared.data(from: remoteURL)
        if let res = res as? HTTPURLResponse, res.statusCode == 200 {
            try data.write(to: url)
        }
    }
    
    func cancel(resumeDataURL: URL?) {
        
    }
}
