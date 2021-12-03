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

    func testDay3() throws {
        let input = """
00100
11110
10110
10111
10101
01111
00111
11100
10000
11001
00010
01010
"""
        let (a, b) = day3(input)
        XCTAssertEqual(a, 198)
        XCTAssertEqual(b, 230)
    }
}
