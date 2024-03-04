import XCTest
@testable import LogFoundation

final class LevelFormattersTests: XCTestCase {
    private let formatters = LevelFormatterStorage()
    
    func testDefault() throws {
        let formatter = formatters[nil]
        XCTAssertEqual(formatter.string(from: .debug), "#DEBUG")
        XCTAssertEqual(formatter.string(from: .info), "#INFO")
        XCTAssertEqual(formatter.string(from: .warn), "#WARN")
        XCTAssertEqual(formatter.string(from: .error), "#ERROR")
        XCTAssertEqual(formatter.string(from: .fatal), "#FATAL")
    }
    
    func testUpperExplicit() throws {
        let formatter = formatters["upper"]
        XCTAssertEqual(formatter.string(from: .debug), "#DEBUG")
        XCTAssertEqual(formatter.string(from: .info), "#INFO")
        XCTAssertEqual(formatter.string(from: .warn), "#WARN")
        XCTAssertEqual(formatter.string(from: .error), "#ERROR")
        XCTAssertEqual(formatter.string(from: .fatal), "#FATAL")
    }
    
    func testPlainUpperMonochromeExplicit() throws {
        let formatter = formatters["plain|upper|mono"]
        XCTAssertEqual(formatter.string(from: .debug), "DEBUG")
        XCTAssertEqual(formatter.string(from: .info), "INFO")
        XCTAssertEqual(formatter.string(from: .warn), "WARN")
        XCTAssertEqual(formatter.string(from: .error), "ERROR")
        XCTAssertEqual(formatter.string(from: .fatal), "FATAL")
    }
    
    func testUpperMonochromeExplicit() throws {
        let formatter = formatters["upper|mono"]
        XCTAssertEqual(formatter.string(from: .debug), "#DEBUG")
        XCTAssertEqual(formatter.string(from: .info), "#INFO")
        XCTAssertEqual(formatter.string(from: .warn), "#WARN")
        XCTAssertEqual(formatter.string(from: .error), "#ERROR")
        XCTAssertEqual(formatter.string(from: .fatal), "#FATAL")
    }
    
    func testMonochromeUpperExplicit() throws {
        let formatter = formatters["mono|upper"]
        XCTAssertEqual(formatter.string(from: .debug), "#DEBUG")
        XCTAssertEqual(formatter.string(from: .info), "#INFO")
        XCTAssertEqual(formatter.string(from: .warn), "#WARN")
        XCTAssertEqual(formatter.string(from: .error), "#ERROR")
        XCTAssertEqual(formatter.string(from: .fatal), "#FATAL")
    }
    
    func testInvalidCasing() throws {
        let formatter = formatters["fruit"]
        XCTAssertEqual(formatter.string(from: .debug), "#DEBUG")
        XCTAssertEqual(formatter.string(from: .info), "#INFO")
        XCTAssertEqual(formatter.string(from: .warn), "#WARN")
        XCTAssertEqual(formatter.string(from: .error), "#ERROR")
        XCTAssertEqual(formatter.string(from: .fatal), "#FATAL")
    }
    
    func testLower() throws {
        let formatter = formatters["lower"]
        XCTAssertEqual(formatter.string(from: .debug), "#debug")
        XCTAssertEqual(formatter.string(from: .info), "#info")
        XCTAssertEqual(formatter.string(from: .warn), "#warn")
        XCTAssertEqual(formatter.string(from: .error), "#error")
        XCTAssertEqual(formatter.string(from: .fatal), "#fatal")
    }
    
    func testCap() throws {
        let formatter = formatters["cap"]
        XCTAssertEqual(formatter.string(from: .debug), "#Debug")
        XCTAssertEqual(formatter.string(from: .info), "#Info")
        XCTAssertEqual(formatter.string(from: .warn), "#Warn")
        XCTAssertEqual(formatter.string(from: .error), "#Error")
        XCTAssertEqual(formatter.string(from: .fatal), "#Fatal")
    }
    
    func testInvalidCasingWithAnsiColoring() throws {
        let formatter = formatters["ansi"]
        XCTAssertEqual(formatter.string(from: .debug), "\u{001B}[0;32m#DEBUG\u{001B}[0;0m")
        XCTAssertEqual(formatter.string(from: .info), "\u{001B}[0;0m#INFO\u{001B}[0;0m")
        XCTAssertEqual(formatter.string(from: .warn), "\u{001B}[0;33m#WARN\u{001B}[0;0m")
        XCTAssertEqual(formatter.string(from: .error), "\u{001B}[0;31m#ERROR\u{001B}[0;0m")
        XCTAssertEqual(formatter.string(from: .fatal), "\u{001B}[0;31m#FATAL\u{001B}[0;0m")
    }
    
    func testGetMultiple() throws {
        let a = "upper"
        let b = "lower"
        XCTAssertEqual(formatters[a].string(from: .info), "#INFO")
        XCTAssertEqual(formatters[b].string(from: .info), "#info")
        XCTAssertEqual(formatters[a].string(from: .debug), "#DEBUG")
        XCTAssertEqual(formatters[b].string(from: .debug), "#debug")
    }
}
