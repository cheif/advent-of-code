import AdventOfCode
import Shared
import XCTest

extension SolutionProtocol {
    func testPart1() {
        XCTAssertEqual(part1(input: testInput), testResult.0)
    }

    func testPart2() {
        XCTAssertEqual(part2(input: part2TestInput ?? testInput), testResult.1)
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

    override class var defaultTestSuite: XCTestSuite {
        let suite = XCTestSuite(forTestCaseClass: TestRunner.self)

        let years = [2022, 2023]
        let days = (1...25)
        for year in years {
            for day in days {
                if let solution = AdventOfCode.solution(year: year, day: day) {
                    let part1 = TestSolution(selector: #selector(TestSolution.runPart1))
                    part1.solution = solution
                    suite.addTest(part1)

                    let part2 = TestSolution(selector: #selector(TestSolution.runPart2))
                    part2.solution = solution
                    suite.addTest(part2)
                }
            }
        }
        return suite
    }
}

class TestSolution: XCTestCase {
    var solution: (any SolutionProtocol)!

    func runPart1() {
        solution.testPart1()
    }

    func runPart2() {
        solution.testPart2()
    }
}
