import Foundation

public struct LogEntry: Codable {
    var message: String
    var level: LogLevel
    var date: Date
    var module: String
    var file: String
    var function: String
    var line: UInt
}
