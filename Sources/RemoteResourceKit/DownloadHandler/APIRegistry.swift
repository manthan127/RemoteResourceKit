//
//  File.swift
//  
//
//  Created by Home on 21/12/25.
//

import Foundation

actor APIRegistry {
    private(set) var registry: [URLRequest: URLSessionDownloadTask] = [:]
    
    func containsEntry(for url: URLRequest) -> Bool {
        registry[url] != nil
    }
    
    func create(remoteURL: URLRequest, task: URLSessionDownloadTask) {
        registry[remoteURL] = task
    }
    
    func clear() {
        registry = [:]
    }
}
