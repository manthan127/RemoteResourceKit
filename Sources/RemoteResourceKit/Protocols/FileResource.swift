//
//  File.swift
//
//
//  Created by Home on 15/12/25.
//

import Foundation

public typealias URLAsyncHandler = (URL) async -> Void
public typealias ErrorAsyncHandler = (Error) async -> Void

// TODO: - need to manage encapsulation of the variable names
public protocol FileResource: FileRepresentative {
    var name: String? {get}
    var urlRequest: URLRequest {get}
    
    var downloadComplete: URLAsyncHandler? {get set}
    var errorHandler: ErrorAsyncHandler? {get set}
}

internal extension FileResource {
    public func iterate(at path: URL, map: inout [URLRequest: [FileDestination]]) {
        map[urlRequest, default: []].append(.init(folderURL: path, fileRepresentative: self))
    }
    
    var fileName: String  {
        name ?? urlRequest.url!.lastPathComponent
    }
}

public extension FileResource {
    func onDownloadComplete(action: @escaping URLAsyncHandler) -> Self {
        var copy = self
        copy.downloadComplete = action
        return copy
    }
    func onError(action: @escaping ErrorAsyncHandler) -> Self {
        var copy = self
        copy.errorHandler = action
        return copy
    }
}
