
import Foundation

public typealias URLAsyncHandler = (URL) -> Void
public typealias ErrorAsyncHandler = (Error) -> Void
public typealias DownloadProgressHandler = (Double) -> Void
public typealias DownloadProgressDataHandler = (_ bytesWritten: Int64, _ totalBytesWritten: Int64, _ totalBytesExpectedToWrite: Int64) -> Void

public struct CompletionsGroup {
    internal var downloadComplete: URLAsyncHandler?
    internal var errorHandler: ErrorAsyncHandler?
    internal var downloadProgressHandler: DownloadProgressHandler?
    internal var downloadProgressDataHandler: DownloadProgressDataHandler?
}
