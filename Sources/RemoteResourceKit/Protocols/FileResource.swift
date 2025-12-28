//
//  File.swift
//
//
//  Created by Home on 15/12/25.
//

import Foundation

public protocol FileResource: FileRepresentative {
    var remoteURL: URL {get}
}

public extension FileResource {
    func iterate(at path: URL, map: inout [URL: [(URL, FileRepresentative)]]) {
        let url = createURL(path: path, isDirectory: false)
        map[remoteURL, default: []].append((url, self))
    }
}
