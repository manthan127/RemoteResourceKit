// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

struct X: DownloadGroup {
    var body: [any FileRepresentative] {
    
//    var body: some FileRepresentative {
        Folder(name: "folderName") {
            Folder(name: "folderName22") {
                File(name: "filename.txt", urlRequest: URLRequest(url: URL(string: "URL/to/My/asset")!))
            }
        }
        
        //        Folder(name: "folderNa") {
        //
        //        }
    }
    
    var baseURL: URL = URL(string: "")!
}


func x() async {
    await DownloadSession(resumeDataURL: nil).download(X())
}
