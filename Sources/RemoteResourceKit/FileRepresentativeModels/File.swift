//
//  File.swift
//
//
//  Created by Home on 15/12/25.
//

import Foundation

public struct File: FileResource {
    public var name: String
    public var urlRequest: URLRequest
    
    public init(name: String, urlRequest: URLRequest) {
        self.name = name
        self.urlRequest = urlRequest
    }
    
    public init(name: String, url: URL) {
        self.name = name
        self.urlRequest = URLRequest(url: url)
    }
    
    public init?(name: String, urlString: String) {
        if let url = URL(string: urlString) {
            self.name = name
            self.urlRequest = URLRequest(url: url)
        } else {
            return nil
        }
    }
}
