//
//  File.swift
//
//
//  Created by Home on 15/12/25.
//

import Foundation

@dynamicMemberLookup
public protocol FileResource: FileRepresentative {
    var name: String? {get}
    var urlRequest: URLRequest {get}
    
    var completionsGroup: CompletionsGroup {get set}
}

public extension FileResource {
    func onDownloadComplete(action: @escaping URLAsyncHandler) -> Self {
        setting(\.downloadComplete, to: action)
    }
    func onError(action: @escaping ErrorAsyncHandler) -> Self {
        setting(\.errorHandler, to: action)
    }
    
    func downloadProgress(action: @escaping DownloadProgressHandler) -> Self {
        setting(\.downloadProgressHandler, to: action)
    }
    
    func downloadProgressData(action: @escaping DownloadProgressDataHandler) -> Self {
        setting(\.downloadProgressDataHandler, to: action)
    }
}

public extension FileResource {
    subscript<T>(dynamicMember keyPath: WritableKeyPath<CompletionsGroup, T>) -> T {
        get {
            completionsGroup[keyPath: keyPath]
        }
        set {
            completionsGroup[keyPath: keyPath] = newValue
        }
    }
    
    func iterate(at path: URL, map: inout [URLRequest: [FileDestination]]) {
        map[urlRequest, default: []].append(.init(folderURL: path, fileRepresentative: self))
    }
}

internal extension FileResource {
    var fileName: String  {
        name ?? urlRequest.url!.lastPathComponent
    }

    private func setting<Value>(
        _ keyPath: WritableKeyPath<Self, Value>,
        to newValue: Value
    ) -> Self {
        var copy = self
        copy[keyPath: keyPath] = newValue
        return copy
    }
}
