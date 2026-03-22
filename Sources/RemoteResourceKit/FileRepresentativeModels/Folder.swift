//
//  File 2.swift
//  
//
//  Created by Home on 11/01/26.
//

import Foundation

public struct Folder: FileRepresentative {
    let name: String
    public let properties: URLRequestProperties?
    @ResourceBuilder var resources: ()-> [any FileRepresentative]
    
    public init(name: String, properties: URLRequestProperties? = nil, @ResourceBuilder  resources: @escaping () -> [any FileRepresentative]) {
        self.name = name
        self.resources = resources
        self.properties = properties
    }
    
    internal func iterate(
        at path: URL, parentProperties: URLRequestProperties?,
        map: inout [URLRequest: [FileDestination]], localMapping: inout [URL: Int]
    ) {
        let url = path.appendingPathComponent(name, isDirectory: true)
        resources().loop(url: url, properties: sendingProperties(parentProperties), map: &map, localMapping: &localMapping)
    }
    
    func sendingProperties(_ properties: URLRequestProperties?) -> URLRequestProperties? {
        self.properties ?? properties
    }
}

extension [any FileRepresentative] {
    func loop(
        url: URL, properties: URLRequestProperties?, 
        map: inout [URLRequest: [FileDestination]], localMapping: inout [URL: Int]
    ) {
        self.forEach {
            if let folder = $0.self as? Folder {
                folder.iterate(at: url, parentProperties: properties, map: &map, localMapping: &localMapping)
            } else if let file = $0.self as? File {
                file.iterate(at: url, properties: properties, map: &map, localMapping: &localMapping)
            }
        }
    }
}
