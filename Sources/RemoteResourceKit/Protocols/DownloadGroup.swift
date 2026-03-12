//
//  File.swift
//  
//
//  Created by Home on 15/12/25.
//

import Foundation

public protocol DownloadGroup {
    var baseURL: URL {get}
    var resumeDataURL: URL? {get}
    
    @ResourceBuilder
    var body: [any FileRepresentative] { get }
}

// TODO: - check if it's folder's url
extension DownloadGroup {
    var resumeDataURL: URL? { nil }
}

extension DownloadGroup {
    func makeMapping() -> [URLRequest: [FileDestination]] {
        var map: [URLRequest: [FileDestination]] = [:]
        body.loop(url: baseURL, map: &map)
        return map
    }
}
