import AdventOfCode
import Shared
import XCTest

extension SolutionProtocol {
    func testPart1() {
        XCTAssertEqual(part1(input: testInput), testResult.0)
    }

    func testPart2() {
        XCTAssertEqual(part2(input: testInput), testResult.1)
    }
}

class TestRunner: XCTestCase {
    func testToday() throws {
        let year: Int = Calendar.current.component(.year, from: Date())
        let day: Int = Calendar.current.component(.day, from: Date())
        let solution = try XCTUnwrap(AdventOfCode.solution(year: year, day: day))
        solution.testPart1()
        solution.testPart2()
    }

    func testAll() {
        let years = [2022, 2023]
        let days = (1...25)
        for year in years {
            for day in days {
                if let solution = AdventOfCode.solution(year: year, day: day) {
                    solution.testPart1()
                    solution.testPart2()
                }
            }
        }

    }
}
