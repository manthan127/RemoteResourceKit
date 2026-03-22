
import Foundation

public typealias URLHandler = (URL) -> Void
public typealias ErrorHandler = (Error) -> Void
public typealias DownloadProgressHandler = (Double) -> Void
public typealias DownloadProgressDataHandler = (_ bytesWritten: Int64, _ totalBytesWritten: Int64, _ totalBytesExpectedToWrite: Int64) -> Void

public struct CompletionsGroup {
    internal var downloadComplete: URLHandler?
    internal var errorHandler: ErrorHandler?
    internal var downloadProgressHandler: DownloadProgressHandler?
    internal var downloadProgressDataHandler: DownloadProgressDataHandler?
}
