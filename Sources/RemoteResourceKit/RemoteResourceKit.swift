// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public enum DownloadStrategy {
    case `default`, alwaysDownload, onlyIfMissing
}

public struct URLRequestProperties {
    let httpMethod: String?
    let httpBody: Data?
    let downloadStrategy: DownloadStrategy
    
    init(httpMethod: String? = nil, httpBody: Data? = nil, downloadStrategy: DownloadStrategy = .default) {
        self.httpMethod = httpMethod
        self.httpBody = httpBody
        self.downloadStrategy = downloadStrategy
    }
}

public protocol FileRepresentative {
    var properties: URLRequestProperties? {get}
}
