//
//  File.swift
//  
//
//  Created by Home on 28/12/25.
//

import Foundation

actor DownloadHandlerFactory {
    private init() {}
    static let shared = DownloadHandlerFactory()
    
    private var storage: [Int: DownloadHandler] = [:]
    
    func object(for group: any DownloadGroup) -> DownloadHandler {
        if let handler = storage[group.hashValue] {
            return handler
        } else {
            let handler = DownloadHandler(resumeDataURL: group.resumeDataURL)
            storage[group.hashValue] = handler
            return handler
        }
    }
}
