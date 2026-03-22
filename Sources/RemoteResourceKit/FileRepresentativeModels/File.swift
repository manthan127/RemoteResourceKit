//
//  File.swift
//
//
//  Created by Home on 15/12/25.
//

import Foundation

@dynamicMemberLookup
public struct File: FileRepresentative {
    var completionsGroup = CompletionsGroup()
    
    let name: String?
    let urlRequest: URLRequest?
    let url: URL?
    
    /// Right now user will be able to overwrite pares's seted value in child but, will not be able to remove them by setting properties to nil,
    /// instead please pass an empty object
    public let properties: URLRequestProperties?
    
    public init(name: String?, urlRequest: URLRequest) {
        self.name = name
        self.urlRequest = urlRequest
        self.properties = nil
        self.url = nil
    }
    
    public init(name: String?, url: URL, properties: URLRequestProperties? = nil) {
        self.name = name
        self.url = url
        self.properties = properties
        self.urlRequest = nil
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
    func onDownloadComplete(action: @escaping URLHandler) -> Self {
        setting(\.downloadComplete, to: action)
    }
    func onError(action: @escaping ErrorHandler) -> Self {
        setting(\.errorHandler, to: action)
    }
    
    func downloadProgress(action: @escaping DownloadProgressHandler) -> Self {
        setting(\.downloadProgressHandler, to: action)
    }
    
    func downloadProgressData(action: @escaping DownloadProgressDataHandler) -> Self {
        setting(\.downloadProgressDataHandler, to: action)
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

internal extension File {
    func makeProperty(properties: URLRequestProperties?) -> URLRequestProperties {
        self.properties ?? properties ?? URLRequestProperties()
    }
    
    func getUrlRequest(properties: URLRequestProperties) -> URLRequest {
        if let urlRequest { return urlRequest }
        
        guard let url else {fatalError()}
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = properties.httpMethod
        urlRequest.httpBody  = properties.httpBody
        
        return urlRequest
    }
    
    func iterate(
        at path: URL, properties: URLRequestProperties?,
        map: inout [URLRequest: [FileDestination]], localMapping: inout [URL: Int]
    ) {
        let properties = makeProperty(properties: properties)
        let urlRequest = getUrlRequest(properties: properties)
        
        let destination = FileDestination(folderURL: path, properties: properties, fileRepresentative: self)
        localMapping[destination.destinationURL.standardized, default: 0] += 1
        map[urlRequest, default: []].append(destination)
    }
    
    var fileName: String  {
        if let name = name ?? urlRequest?.url?.lastPathComponent ?? url?.lastPathComponent {
            return name
        } else {
            fatalError()
        }
    }
}
