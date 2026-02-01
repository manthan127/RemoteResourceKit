//
//  File.swift
//  
//
//  Created by Home on 21/12/25.
//

import Foundation

actor APIRegistry {
    private(set) var registry: [URLRequest: URLSessionTask] = [:]
    
    func containsEntry(for url: URLRequest) -> Bool {
        registry[url] != nil
    }
    
    func create(remoteURL: URLRequest, task: URLSessionTask) {
        registry[remoteURL] = task
    }
    
    func clear() {
        registry = [:]
    }
}
