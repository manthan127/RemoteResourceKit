//
//  File 2.swift
//  
//
//  Created by Home on 20/12/25.
//

import Foundation

// can optimize by collection the mapping in batch and than saving the mapping in only one call
actor ResumeDataHandler {
    nonisolated let url: URL
    
    nonisolated var plistURL: URL {
        url.appendingPathComponent("mapping.plist")
    }
    
    /// In-memory mapping: remoteURL → filename
    private var mapping: [URL: String]
    
    /// Initialize with the URL where `mapping.plist` should live
    init(url: URL) {
        self.url = url
        self.mapping = Self.loadMappingFromDisk(plistURL: url.appendingPathComponent("mapping.plist"))
    }
    
    // MARK: - Public API
    /// Saves the remote URL to the plist and the data to a sibling file.
    func save(remoteURL: URL, data: Data) throws {
        let fileName = UUID().uuidString
        mapping[remoteURL] = fileName
        
        // Save the data file
        let directory = url.deletingLastPathComponent()
        let dataFileURL = directory.appendingPathComponent(fileName)
        try data.write(to: dataFileURL, options: .atomic)
        
        // Persist updated mapping
        try saveMappingToDisk()
    }
    
    func data(remoteURL: URL) -> Data? {
        guard let name = mapping[remoteURL] else { return nil }
        return try? Data(contentsOf: url.appendingPathComponent(name))
    }
    
    // MARK: - Persistence
    /// Loads mapping.plist into memory
    private static func loadMappingFromDisk(plistURL: URL) -> [URL: String] {
        guard
            let data = try? Data(contentsOf: plistURL),
            let raw = try? PropertyListSerialization.propertyList(
                from: data,
                options: [],
                format: nil
            ) as? [String: String]
        else {
            return [:]
        }
        
        return Dictionary(
            uniqueKeysWithValues: raw.compactMap { key, value in
                guard let url = URL(string: key) else { return nil }
                return (url, value)
            }
        )
    }
    
    /// Saves in-memory mapping to mapping.plist
    private func saveMappingToDisk() throws {
        let raw: [String: String] = mapping.reduce(into: [:]) {
            $0[$1.key.absoluteString] = $1.value
        }
        
        let data = try PropertyListSerialization.data(
            fromPropertyList: raw,
            format: .xml,
            options: 0
        )
        
        try data.write(to: plistURL, options: .atomic)
    }
}
