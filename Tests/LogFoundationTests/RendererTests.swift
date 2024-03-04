//
//  RendererTests.swift
//  
//
//  Created by Blair Mitchelmore on 2024-03-03.
//

import XCTest
@testable import LogFoundation

final class RendererTests: XCTestCase {
    private let entry = LogEntry(
        message: "Hello world",
        level: .info,
        date: .distantPast,
        module: "Module",
        file: "File.swift",
        function: "Function",
        line: 69
    )
    
    func testRendererAllFields() throws {
        let render = try BuildRenderer(using: "{{date}}|{{level}}|{{module}}|{{file}}|{{function}}|{{line}}|{{message}}")
        XCTAssertEqual(render(entry), "0001-01-01T00:00:00Z|#INFO|Module|File.swift|Function|69|Hello world")
    }
    
    func testRendererAnsiColors() throws {
        let render = try BuildRenderer(using: "{{level|lower|ansi}} {{message}}")
        XCTAssertEqual(render(entry), "\u{001B}[0;0m#info\u{001B}[0;0m Hello world")
    }
    
    func testRendererShortDate() throws {
        let render = try BuildRenderer(using: "{{date|short}} {{message}}")
        XCTAssertEqual(render(entry), "1-12-31, 6:42 PM Hello world")
    }
    
    func testRendererLongDate() throws {
        let render = try BuildRenderer(using: "{{date|long}} {{message}}")
        XCTAssertEqual(render(entry), "December 31, 1 at 6:42:28 PM GMT-5:17:32 Hello world")
    }
    
    func testRendererDefaultDate() throws {
        let render = try BuildRenderer(using: "{{date}} {{message}}")
        XCTAssertEqual(render(entry), "0001-01-01T00:00:00Z Hello world")
    }
    
    func testRendererExtraBraceEarly() throws {
        let render = try BuildRenderer(using: "{{{date}} {{message}}")
        XCTAssertEqual(render(entry), "{0001-01-01T00:00:00Z Hello world")
    }
    
    func testRendererExtraBraceLate() throws {
        let render = try BuildRenderer(using: "{{date}}} {{message}}")
        XCTAssertEqual(render(entry), "0001-01-01T00:00:00Z} Hello world")
    }
    
    func testRendererSingleBrace() throws {
        let render = try BuildRenderer(using: "{date} {{message}}")
        XCTAssertEqual(render(entry), "{date} Hello world")
    }
    
    func testRendererEmptyProperty() throws {
        XCTAssertThrowsError(try BuildRenderer(using: "{{}}"))
    }
    
    func testRendererUnknownProperty() throws {
        XCTAssertThrowsError(try BuildRenderer(using: "{{jumbo}}"))
    }
    
    func testRendererExtraCurlyBraces() throws {
        let render = try BuildRenderer(using: "{hello} {{message}} } something {")
        XCTAssertEqual(render(entry), "{hello} Hello world } something {")
    }
}
