//
//  RendererTests.swift
//  
//
//  Created by Blair Mitchelmore on 2024-03-03.
//

import XCTest
@testable import Logger

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
        let render = try renderer(using: "{{date}}|{{level}}|{{module}}|{{file}}|{{function}}|{{line}}|{{message}}")
        XCTAssertEqual(render(entry), "0001-01-01T00:00:00Z|INFO|Module|File.swift|Function|69|Hello world")
    }
    
    func testRendererShortDate() throws {
        let render = try renderer(using: "{{date|short}} {{message}}")
        XCTAssertEqual(render(entry), "1-12-31, 6:42 PM Hello world")
    }
    
    func testRendererLongDate() throws {
        let render = try renderer(using: "{{date|long}} {{message}}")
        XCTAssertEqual(render(entry), "December 31, 1 at 6:42:28 PM GMT-5:17:32 Hello world")
    }
    
    func testRendererDefaultDate() throws {
        let render = try renderer(using: "{{date}} {{message}}")
        XCTAssertEqual(render(entry), "0001-01-01T00:00:00Z Hello world")
    }
    
    func testRendererInvalidExtraBraceEarly() throws {
        XCTAssertThrowsError(try renderer(using: "{{{date}} {{message}}"))
    }
    
    func testRendererInvalidExtraBraceLate() throws {
        XCTAssertThrowsError(try renderer(using: "{{date}}} {{message}}"))
    }
    
    func testRendererInvalidPartialBrace() throws {
        XCTAssertThrowsError(try renderer(using: "{date} {{message}}"))
    }
    
    func testRendererInvalidEmptyProperty() throws {
        XCTAssertThrowsError(try renderer(using: "{{}}"))
    }
    
    func testRendererInvalidUnknownProperty() throws {
        XCTAssertThrowsError(try renderer(using: "{{jumbo}}"))
    }
}
