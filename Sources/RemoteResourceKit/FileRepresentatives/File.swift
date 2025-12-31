//
//  File.swift
//
//
//  Created by Home on 15/12/25.
//

import Foundation

public struct Folder: FileRepresentative {
    public let name: String
    @ResourceBuilder var resources: ()-> [any FileRepresentative]
    
    internal func iterate(at path: URL, map: inout [URLRequest: [FileDestination]]) {
        let url = createURL(path: path, isDirectory: true)
        resources().forEach {
            $0.iterate(at: url, map: &map)
        }
    }
}


public struct File: FileResource {
    public let name: String
    public let urlRequest: URLRequest
}
