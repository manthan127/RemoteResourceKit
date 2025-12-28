//
//  File.swift
//  
//
//  Created by Home on 15/12/25.
//

import Foundation

public protocol DownloadGroup: Hashable {
    var baseURL: URL {get}
    var resumeDataURL: URL? {get}
    
    //    associatedtype F: FileRepresentative
    //
    //    @ResourceBuilder
    //    var body: F { get }
    
    @ResourceBuilder
    var body: [any FileRepresentative] { get }
}

// TODO: - check if it's folder's url
extension DownloadGroup {
    var resumeDataURL: URL? { nil }
}

public extension DownloadGroup {
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(baseURL)
//        if let resumeDataURL {
//            hasher.combine(resumeDataURL)
//        }
//    }
    
    // TODO: - might be issue where two different struct are referring to same local url and are calling api in parrallel(might even have different remote url causing  race condition where one will overwrite other one)
    internal var downloadHandler: DownloadHandler {
        get async {
            await DownloadHandlerFactory.shared.object(for: self)
        }
    }
    
    // TODO: - return all the collected errors and warings
    func download() async {
        let map = makeMapping()
        await downloadHandler.download(map: map)
    }
    
    func cancel() async {
        await downloadHandler.cancel()
    }
}

private extension DownloadGroup {
    func makeMapping() -> [URL: [FileDestination]] {
        var map: [URL: [FileDestination]] = [:]
        body.forEach {
            $0.iterate(at: baseURL, map: &map)
        }
        return map
    }
}
