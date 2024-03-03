import XCTest
@testable import Logger

final class LoggerTests: XCTestCase {
    private let fileManager = FileManager.default
    private let fileName = "test-log.jsonl"
    private lazy var url = fileManager.temporaryDirectory.appending(path: fileName)
    
    struct LogItem: Equatable {
        var level: LogLevel
        var message: String
    }
    
    override func setUpWithError() throws {
        try? fileManager.removeItem(at: url)
    }
    
    override func tearDownWithError() throws {
        try? fileManager.removeItem(at: url)
    }
    
    func testLogger() throws {
        let printed: AliasedLock<[String]> = AliasedLock(initialState: [])
        
        let logger = Logger()
        let console = try ConsoleLogger(format: "{{level}} {{message}}", output: { str in
            printed.withLock { printed in
                printed.append(str)
            }
        })
        let file = FileLogger(
            fileManager: fileManager,
            console: console,
            url: url
        )
        let test = TestLogger()
        logger.add(console)
        logger.add(file)
        logger.add(test)
        
        logger.log(.info, "Log")
        logger.debug("Debug")
        logger.info("Info")
        logger.warn("Warn")
        logger.error("Error")
        logger.fatal("Fatal")
        
        let entries = test.lock.withLock({ $0 }).map {
            LogItem(level: $0.level, message: $0.message)
        }
        XCTAssertEqual(entries, [
            LogItem(level: .info, message: "Log"),
            LogItem(level: .debug, message: "Debug"),
            LogItem(level: .info, message: "Info"),
            LogItem(level: .warn, message: "Warn"),
            LogItem(level: .error, message: "Error"),
            LogItem(level: .fatal, message: "Fatal")
        ])
        XCTAssertTrue(fileManager.fileExists(atPath: url.path()))
        XCTAssertEqual(printed.withLock({ $0 }), [
            "INFO Log",
            "DEBUG Debug",
            "INFO Info",
            "WARN Warn",
            "ERROR Error",
            "FATAL Fatal"
        ])
    }
}
