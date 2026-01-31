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
    
    public func iterate(at path: URL, map: inout [URLRequest: [FileDestination]]) {
        let url = path.appendingPathComponent(name, isDirectory: true)
        resources().forEach {
            $0.iterate(at: url, map: &map)
        }
    }
}
