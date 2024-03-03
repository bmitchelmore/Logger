import Foundation
import os

private let defaultFormat = "[{{date}}] #{{level}} /{{module}}/{{file}}@{{function}}:{{line}} {{message}}"

public final class ConsoleLogger: LoggerDestination, Sendable {
    private let lock: OSAllocatedUnfairLock<Void>
    private let render: @Sendable (LogEntry) -> String
    private let output: @Sendable (String) -> Void

    public init(format: String? = nil, output: @escaping @Sendable (String) -> Void = { print($0) }) throws {
        self.lock = OSAllocatedUnfairLock()
        self.render = try renderer(using: format ?? defaultFormat)
        self.output = output
    }

    public func log(_ entry: LogEntry) {
        lock.withLock {
            output(render(entry))
        }
    }
}
