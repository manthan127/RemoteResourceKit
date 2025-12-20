//
//  File 2.swift
//  
//
//  Created by Home on 20/12/25.
//

import Foundation

struct AppConfig: Codable {
    var id: UUID
    var serviceURL: URL
}

actor ResumeDataHandler {
    nonisolated let url: URL
    
    /// Initialize with the URL where you want the .plist to live.
    init(url: URL) {
        self.url = url
    }
    
    var dataList: [URL: String] = [:]
    
    /// Saves the remote URL to the plist and the data to a sibling file.
    func save(remoteURL: URL, data: Data) throws {
        let fileName: String = UUID().uuidString
        dataList[remoteURL] = fileName
        
        // 1. Determine path for the sibling data file
        let directory = url.deletingLastPathComponent()
        let dataFileURL = directory.appendingPathComponent(fileName)
        
        // 2. Prepare the dictionary for the plist
        
//        let metadata: [String: Any] = [
//            "remoteURL": remoteURL.absoluteString,
//            "localFileName": fileName,
//            "timestamp": Date()
//        ]
        
        // 3. Save the sibling data file
        try data.write(to: dataFileURL, options: .atomic)
        
        // 4. Save the plist file
        
//        let plistData = try PropertyListSerialization.data(
//            fromPropertyList: metadata,
//            format: .xml,
//            options: 0
//        )
//        try plistData.write(to: url, options: .atomic)
    }
    
    func save() {
        
    }
    
    /// Loads the metadata from the plist as a dictionary
    func loadMetadata() -> [String: Any]? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? PropertyListSerialization.propertyList(
            from: data,
            options: [],
            format: nil
        ) as? [String: Any]
    }
    
    /// Helper to get the sibling data based on the name stored in the plist
    func loadSiblingData() -> Data? {
        guard let metadata = loadMetadata(),
              let fileName = metadata["localFileName"] as? String else { return nil }
        
        let dataFileURL = url.deletingLastPathComponent().appendingPathComponent(fileName)
        return try? Data(contentsOf: dataFileURL)
    }
}
