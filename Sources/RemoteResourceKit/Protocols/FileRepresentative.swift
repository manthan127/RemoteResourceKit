//
//  File.swift
//  
//
//  Created by Home on 15/12/25.
//

import Foundation

// TODO: - add something to verify that name is valid or not
public protocol FileRepresentative {}

extension FileRepresentative {
    func iterate(at path: URL, map: inout [URLRequest: [FileDestination]]) {}
}

// TODO: - Probably can use better name
struct FileDestination {
    let folderURL: URL
    let fileRepresentative: FileResource
    
    var destinationURL: URL {
        folderURL.appendingPathComponent(fileRepresentative.fileName)
    }
}
