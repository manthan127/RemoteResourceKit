//
//  File.swift
//
//
//  Created by Home on 15/12/25.
//

import Foundation

public protocol FileResource: FileRepresentative {
    var urlRequest: URLRequest {get}
}

internal extension FileResource {
    func iterate(at path: URL, map: inout [URLRequest: [FileDestination]]) {
        let url = createURL(path: path, isDirectory: false)
        map[urlRequest, default: []].append(.init(url: url, fileRepresentative: self))
    }
}
