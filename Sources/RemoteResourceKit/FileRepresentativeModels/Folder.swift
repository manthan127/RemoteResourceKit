//
//  File 2.swift
//  
//
//  Created by Home on 11/01/26.
//

import Foundation

public struct Folder: FileRepresentative {
    public let name: String
    @ResourceBuilder var resources: ()-> [any FileRepresentative]
    
    internal func iterate(at path: URL, map: inout [URLRequest: [FileDestination]]) {
        let url = path.appendingPathComponent(name, isDirectory: true)
        resources().forEach {
            $0.iterate(at: url, map: &map)
        }
    }
}
