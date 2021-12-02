@testable import AdventOfCode
import XCTest

final class AdventOfCodeTests: XCTestCase {
    func testDay1() throws {
        let input = """
199
200
208
210
200
207
240
269
260
263
"""
        let (a, b) = day1(input)
        XCTAssertEqual(a, 7)
        XCTAssertEqual(b, 5)
    }
}

func XCTAssertEqual(_ lhs: (Int, Int), _ rhs: (Int, Int)) {
    XCTAssertEqual(lhs.0, rhs.0)
    XCTAssertEqual(lhs.1, rhs.1)
}
