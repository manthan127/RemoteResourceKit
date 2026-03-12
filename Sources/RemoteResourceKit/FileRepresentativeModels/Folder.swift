//
//  File 2.swift
//  
//
//  Created by Home on 11/01/26.
//

import Foundation

public struct Folder: FileRepresentative {
    public let name: String
    @ResourceBuilder public var resources: ()-> [any FileRepresentative]
    
    public init(name: String, @ResourceBuilder  resources: @escaping () -> [any FileRepresentative]) {
        self.name = name
        self.resources = resources
    }
    
    internal func iterate(at path: URL, map: inout [URLRequest: [FileDestination]]) {
        let url = path.appendingPathComponent(name, isDirectory: true)
        resources().loop(url: url, map: &map)
    }
}

extension [any FileRepresentative] {
    func loop(url: URL, map: inout [URLRequest: [FileDestination]]) {
        self.forEach {
            if let folder = $0.self as? Folder {
                folder.iterate(at: url, map: &map)
            } else if let file = $0.self as? File {
                file.iterate(at: url, map: &map)
            }
        }
    }
}
