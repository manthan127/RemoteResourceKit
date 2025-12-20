// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

//public extension Array where Element == Resource {
//    func download() async -> [Error?] {
//        var arrErr: [Error?] = []
//        let tasks = self.map { resource in
//            Task {
//                try await resource.download()
//            }
//        }
//        
//        for t in tasks {
//            do {
//                try await t.value
//                arrErr.append(nil)
//            } catch {
//                arrErr.append(error)
//            }
//        }
//        return arrErr
//    }
//}
