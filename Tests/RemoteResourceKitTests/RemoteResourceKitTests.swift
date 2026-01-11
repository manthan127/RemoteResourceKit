import XCTest
@testable import RemoteResourceKit

final class RemoteResourceKitTests: XCTestCase {
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
    }
}

struct X: DownloadGroup {
    var baseURL: URL = URL(string: "")!
    
    var body: [any FileRepresentative] {
        //    var body: some FileRepresentative {
        Folder(name: "folderName") {
            Folder(name: "folderName22") {
                File(name: "filename.txt", urlRequest: URLRequest(url: URL(string: "URL/to/My/asset")!))
                
                if Int.random(in: 0...5) < 2 {
                    File(name: "filename.txt", url: URL(string: "URL/to/My/asset")!)
                }
                File(name: "filename.txt", urlString: "URL/to/My/asset")
            }
            File(name: "filename.txt", urlString: "URL/to/My/asset")
        }
        
        File(name: "filename.txt", urlRequest: URLRequest(url: URL(string: "URL/to/My/asset")!))
        Folder(name: "folderNa") {
            
        }
    }
}


func x() async {
    await DownloadSession(resumeDataURL: nil).download(X())
}

