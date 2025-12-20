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
    
    var body: some FileRepresentative {
        Folder(name: "folderName") {
            Folder(name: "folderName22") {
                File(name: "filename.txt", remoteURL: URL(string: "URL/to/My/asset")!)
//                Resource(remoteURL: URL(string: "")!, localURL: URL(string: "")!)
            }
        }
    }
}
