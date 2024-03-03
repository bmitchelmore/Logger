import Foundation
import os

enum FileLoggerError: Error {
    case fileCreateFailed
}

final public class FileLogger: LoggerDestination, @unchecked Sendable {
    private let lock: OSAllocatedUnfairLock<Void>
    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let console: ConsoleLogger?
    private let url: URL
    private var fileExists: Bool!

    public init(fileManager: FileManager = .default, console: ConsoleLogger? = nil, url: URL) {
        self.lock = OSAllocatedUnfairLock()
        self.fileManager = fileManager
        self.encoder = JSONEncoder()
        self.console = console
        self.url = url
        self.fileExists = nil
    }

    public func log(_ entry: LogEntry) {
        lock.withLock {
            do {
                var data = try encoder.encode(entry)
                data.append(contentsOf: [0x0a])
                if fileExists == nil {
                    fileExists = fileManager.fileExists(atPath: url.path)
                }
                if fileExists {
                    let file = try FileHandle(forUpdating: url)
                    try file.seekToEnd()
                    try file.write(contentsOf: data)
                    try file.synchronize()
                    try file.close()
                } else {
                    let success = fileManager.createFile(
                        atPath: url.path,
                        contents: data
                    )
                    fileExists = true
                    guard success else {
                        throw FileLoggerError.fileCreateFailed
                    }
                }
            } catch {
                console?.error("Failed to write log entry: \(error)")
            }
        }
    }
}
