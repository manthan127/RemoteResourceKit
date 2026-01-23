//
//  File.swift
//
//
//  Created by Home on 15/12/25.
//

import Foundation

public protocol FileResource: FileRepresentative {
    var name: String? {get}
    var urlRequest: URLRequest {get}
}

internal extension FileResource {
    func iterate(at path: URL, map: inout [URLRequest: [FileDestination]]) {
        map[urlRequest, default: []].append(.init(folderURL: path, fileRepresentative: self))
    }
    
    var fileName: String  {
        name ?? urlRequest.url!.lastPathComponent
    }
}
