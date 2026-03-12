//
//  File.swift
//  
//
//  Created by Home on 08/03/26.
//

import Foundation

// TODO: - Probably can use better name
internal struct FileDestination {
    let folderURL: URL
    let fileRepresentative: File
    
    var destinationURL: URL {
        folderURL.appendingPathComponent(fileRepresentative.fileName)
    }
}

extension FileDestination {
    func copyAndSendMessage(_ tempURL: URL) {
        do {
            try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
            
            try FileManager.default.copyItem(at: tempURL, to: destinationURL)
            
            fileRepresentative.downloadComplete?(destinationURL)
        } catch {
            fileRepresentative.errorHandler?(error)
        }
    }
}

extension [FileDestination] {
    private func notify(_ action: (FileDestination) -> Void) {
        for destination in self {
            action(destination)
        }
    }
    
    func downloadProgressDataHandler(_ bytesWritten: Int64, _ totalBytesWritten: Int64, _ totalBytesExpectedToWrite: Int64) {
        notify { $0.fileRepresentative.downloadProgressDataHandler?(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) }
    }
    func downloadProgressHandler(_ progress: Double) {
        notify { $0.fileRepresentative.downloadProgressHandler?(progress) }
    }
    func errorHandler(_ error: Error) {
        notify { $0.fileRepresentative.errorHandler?(error) }
    }
    
    func copyAndSendMessage(_ tempURL: URL) {
        notify { $0.copyAndSendMessage(tempURL) }
    }
}
