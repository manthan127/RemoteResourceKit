//
//  File.swift
//  
//
//  Created by Home on 21/12/25.
//

import Foundation

actor APIRegistry {
    private(set) var registry: [URL: URLSessionDownloadTask] = [:]
    
    func containsEntry(for url: URL) -> Bool {
        registry[url] != nil
    }
    
    func create(remoteURL: URL, task: URLSessionDownloadTask) {
        registry[remoteURL] = task
    }
    
    func clear() {
        registry = [:]
    }
}
