//
//  File 2.swift
//  
//
//  Created by Home on 19/12/25.
//

import Foundation

enum CacheEntry {
    case inProgress(Task<Void, Error>)
    case ready
}

actor APIRegistry {
    var dict: [URL: URLSessionDownloadTask] = [:]
    
    func set(url: URL, task: URLSessionDownloadTask) {
        dict[url] = task
    }
    
    func remove(url: URL) {
        dict.removeValue(forKey: url)
    }
    
    func get(url: URL)-> URLSessionDownloadTask? {
        dict[url]
    }
}

// TODO: - make option for parallel calling or serial Calling
final class DownloadHandler: NSObject {
    let registry = APIRegistry()
    let plistManager: ResumeDataHandler?
    
    init(resumeDataURL url: URL?) {
        if let url {
            plistManager = ResumeDataHandler(url: url)
        } else {
            plistManager = nil
        }
    }
    
    // TODO: - handle call of this function when cancel is called
    func download(remoteURL: URL, url: URL) async {
        if FileManager.default.fileExists(at: url) {
            return
        }
        
        if let task = await registry.get(url: remoteURL) {
            // same remote url for different local urls
            // CASE 1: - API is completed
            // CASE 2: - API is still running
            return
        }
        
        let task = URLSession.shared.downloadTask(with: URLRequest(url: remoteURL)) { downloadURL, response, error in
            if let error {
                // TODO: - collect and show error to the user
                return
            }
            // TODO: - handle statusCode (not handling right now because the api's response might not return valid statusCode)
            if let downloadURL {
                do {
                    try FileManager.default.moveItem(at: url, to: downloadURL)
                } catch {
                    // TODO: - collect and show error to the user
                }
            }
        }
//        await self.registry.remove(url: remoteURL)
    }
    
    func cancel(remoteURL: URL) async {
        guard let task = await registry.get(url: remoteURL) else { return }
        if let plistManager {
            let data = await task.cancelByProducingResumeData()
            do {
                //TODO: - might need to get the id from paramaters
                
            } catch {
                // TODO: - collect and show error to the user
            }
            
        } else {
            task.cancel()
            await registry.remove(url: remoteURL)
        }
    }
}


extension FileManager {
    func fileExists(at path: URL) -> Bool {
        if #available(iOS 16.0, *) {
            fileExists(atPath: path.path(percentEncoded: false))
        } else {
            fileExists(atPath: path.path)
        }
    }
}

