//
//  File.swift
//  
//
//  Created by Home on 15/12/25.
//

import Foundation

// TODO: - add something to verify that name is valid or not
public protocol FileRepresentative {
    var name: String {get}
    
    func download(at path: URL) async throws
    func cancel(resumeDataURL: URL?)
}


extension FileRepresentative {
    func createURL(path: URL, isDirectory: Bool) -> URL {
        if #available(iOS 16.0, macOS 13.0, *) {
            return path.appending(component: name, directoryHint: isDirectory ? .isDirectory : .notDirectory)
        } else {
            return path.appendingPathComponent(name, isDirectory: isDirectory)
        }
    }
}
