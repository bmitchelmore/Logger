import XCTest
@testable import LogFoundation

final class DateFormattersTests: XCTestCase {
    private let formatters = DateFormatterStorage()
    private let date = Date.distantPast
    
    func testGetDefault() throws {
        let formatter = formatters[nil]
        XCTAssertEqual(formatter.string(from: date), "0001-01-01T00:00:00Z")
    }
    
    func testGetShort() throws {
        let formatter = formatters["short"]
        XCTAssertEqual(formatter.string(from: date), "1-12-31, 6:42 PM")
    }
    
    func testGetMedium() throws {
        let formatter = formatters["medium"]
        XCTAssertEqual(formatter.string(from: date), "Dec 31, 1 at 6:42:28 PM")
    }
    
    func testGetLong() throws {
        let formatter = formatters["long"]
        XCTAssertEqual(formatter.string(from: date), "December 31, 1 at 6:42:28 PM GMT-5:17:32")
    }
    
    func testGetFull() throws {
        let formatter = formatters["full"]
        XCTAssertEqual(formatter.string(from: date), "Friday, December 31, 1 at 6:42:28 PM GMT-05:17:32")
    }
    
    func testGetCustom() throws {
        let formatter = formatters["YYYY/MM/dd 'at' hh:mm:ss"]
        XCTAssertEqual(formatter.string(from: date), "0001/12/31 at 06:42:28")
    }
    
    func testGetMultiple() throws {
        let a = "YYYY/MM/dd"
        let b = "MM-dd-YYYY"
        XCTAssertEqual(formatters[a].string(from: date), "0001/12/31")
        XCTAssertEqual(formatters[b].string(from: date), "12-31-0001")
        XCTAssertEqual(formatters[a].string(from: date), "0001/12/31")
        XCTAssertEqual(formatters[b].string(from: date), "12-31-0001")
    }
}
