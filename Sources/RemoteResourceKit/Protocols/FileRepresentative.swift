//
//  File.swift
//  
//
//  Created by Home on 15/12/25.
//

import Foundation

// TODO: - add something to verify that name is valid or not
public protocol FileRepresentative {
    func iterate(at path: URL, map: inout [URLRequest: [FileDestination]])
}

// TODO: - Probably can use better name
public struct FileDestination {
    let folderURL: URL
    let fileRepresentative: FileResource
    
    var destinationURL: URL {
        folderURL.appendingPathComponent(fileRepresentative.fileName)
    }
}


internal extension FileDestination {
    func copyAndSendMessage(_ tempURL: URL) {
        do {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
            
            try FileManager.default.copyItem(at: tempURL, to: destinationURL)
            
            Task {
                await fileRepresentative.downloadComplete?(destinationURL)
            }
        } catch {
            Task {
                await fileRepresentative.errorHandler?(error)
            }
        }
    }
}
