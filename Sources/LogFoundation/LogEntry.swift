import Foundation

public struct LogEntry: Codable {
    public var message: String
    public var level: LogLevel
    public var date: Date
    public var module: String
    public var file: String
    public var function: String
    public var line: UInt
    
    public init(message: String, level: LogLevel, date: Date, module: String, file: String, function: String, line: UInt) {
        self.message = message
        self.level = level
        self.date = date
        self.module = module
        self.file = file
        self.function = function
        self.line = line
    }
}
