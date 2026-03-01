//
//  File.swift
//
//
//  Created by Home on 15/12/25.
//

import Foundation

public struct File: FileResource {
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
}
