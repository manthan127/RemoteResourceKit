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
}

extension FileRepresentative {
    func iterate(at path: URL, map: inout [URL: [FileDestination]]) {}
    
    func createURL(path: URL, isDirectory: Bool) -> URL {
        if #available(iOS 16.0, macOS 13.0, *) {
            return path.appending(component: name, directoryHint: isDirectory ? .isDirectory : .notDirectory)
        } else {
            return path.appendingPathComponent(name, isDirectory: isDirectory)
        }
    }
}

// TODO: - Probably can use better name
struct FileDestination {
    let url: URL
    let fileRepresentative: FileRepresentative
}
