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

    func testDay2() throws {
        let input = """
forward 5
down 5
forward 8
up 3
down 8
forward 2
"""
        let (a, b) = day2(input)
        XCTAssertEqual(a, 150)
        XCTAssertEqual(b, 900)
    }
}
