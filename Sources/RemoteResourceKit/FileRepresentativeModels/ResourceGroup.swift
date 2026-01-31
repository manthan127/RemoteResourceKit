//
//  SwiftUIView.swift
//  
//
//  Created by Home on 29/01/26.
//
import Foundation

public struct ResourceGroup: DownloadGroup {
    public let baseURL: URL
    public let resumeDataURL: URL?
    public let body: [any FileRepresentative]
    
    public init(baseURL: URL, resumeDataURL: URL? = nil, @ResourceBuilder body: () -> [any FileRepresentative]) {
        self.baseURL = baseURL
        self.resumeDataURL = resumeDataURL
        self.body = body()
    }
}
