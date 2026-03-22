//
//  File.swift
//  
//
//  Created by Home on 15/12/25.
//

import Foundation

enum DownloadGroupError: Error {
    case duplicateLocal(urls: [URL])
}

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
    func makeMapping() throws -> [URLRequest: [FileDestination]] {
        var map: [URLRequest: [FileDestination]] = [:]
        var localMapping: [URL: Int] = [:]
        
        body.loop(url: baseURL, properties: nil, map: &map, localMapping: &localMapping)
        let duplicateURLs = localMapping.compactMap { url, count in
            count > 1 ? url : nil
        }
        
        if duplicateURLs.isEmpty {
            return map
        } else {
            throw DownloadGroupError.duplicateLocal(urls: duplicateURLs)
        }
    }
}
