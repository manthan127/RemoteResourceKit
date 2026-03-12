//
//  File.swift
//
//
//  Created by Home on 15/12/25.
//

import Foundation

@dynamicMemberLookup
public struct File: FileRepresentative {
    public var completionsGroup = CompletionsGroup()
    
    public let name: String?
    public let urlRequest: URLRequest
    
    public init(name: String?, urlRequest: URLRequest) {
        self.name = name
        self.urlRequest = urlRequest
    }
    
    public init(name: String?, url: URL) {
        self.name = name
        self.urlRequest = URLRequest(url: url)
    }
    
    subscript<T>(dynamicMember keyPath: WritableKeyPath<CompletionsGroup, T>) -> T {
        get {
            completionsGroup[keyPath: keyPath]
        } set {
            completionsGroup[keyPath: keyPath] = newValue
        }
    }
}

public extension File {
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

internal extension File {
    func iterate(at path: URL, map: inout [URLRequest: [FileDestination]]) {
        map[urlRequest, default: []].append(.init(folderURL: path, fileRepresentative: self))
    }
    
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
