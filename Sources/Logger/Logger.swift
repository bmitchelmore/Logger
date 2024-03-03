import Foundation
import os

public protocol LoggerDestination: Sendable {
    func log(_ entry: LogEntry)
}

private func ExtractModuleAndFile(from fileID: String) -> (module: String, file: String) {
    let parts = fileID.components(separatedBy: "/")
    let module = parts.first!
    let fileName = parts.last!
    return (module, fileName)
}

extension LoggerDestination {
    public func log(
        _ level: LogLevel,
        _ message: @autoclosure () -> String,
        fileID: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        let (module, file) = ExtractModuleAndFile(from: fileID)
        let date = Date()
        let entry = LogEntry(
            message: message(),
            level: level,
            date: date,
            module: module,
            file: file,
            function: function,
            line: line
        )
        log(entry)
    }
    
    public func debug(
        _ message: @autoclosure () -> String,
        fileID: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        log(.debug, message())
    }
    
    public func info(
        _ message: @autoclosure () -> String,
        fileID: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        log(.info, message())
    }
    
    public func warn(
        _ message: @autoclosure () -> String,
        fileID: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        log(.warn, message())
    }
    
    public func error(
        _ message: @autoclosure () -> String,
        fileID: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        log(.error, message())
    }
    
    public func fatal(
        _ message: @autoclosure () -> String,
        fileID: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        log(.fatal, message())
    }
}

public final class Logger: LoggerDestination, @unchecked Sendable {
    private let lock: OSAllocatedUnfairLock<[any LoggerDestination]>

    public init() {
        lock = OSAllocatedUnfairLock(initialState: [])
    }

    public func add(_ destination: any LoggerDestination) {
        lock.withLock { destinations in
            destinations.append(destination)
        }
    }

    public func log(_ entry: LogEntry) {
        lock.withLock { destinations in
            for destination in destinations {
                destination.log(entry)
            }
        }
    }
}
