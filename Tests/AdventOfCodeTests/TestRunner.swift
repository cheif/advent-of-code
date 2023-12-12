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

class Year2022: XCTestCase {
    override class var defaultTestSuite: XCTestSuite {
        createTestSuite(testCase: Year2022.self, year: 2022)
    }
}

class Year2023: XCTestCase {
    override class var defaultTestSuite: XCTestSuite {
        createTestSuite(testCase: Year2023.self, year: 2023)
    }
}

func createTestSuite(testCase: XCTestCase.Type, year: Int) -> XCTestSuite {
    let suite = XCTestSuite(forTestCaseClass: testCase)
    let days = (1...25)
    //        for (year, clsss) in years {
    for day in days {
        if let solution = AdventOfCode.solution(year: year, day: day) {
            suite.addTest(addMethod(testCase: testCase, name: "day_\(day)_part1") {
                solution.testPart1()
            })
            suite.addTest(addMethod(testCase: testCase, name: "day_\(day)_part2") {
                solution.testPart2()
            })
        }
    }
    return suite
}

private func addMethod(testCase: XCTestCase.Type, name: String, block: @escaping () -> Void) -> XCTestCase {
    let cls: AnyClass = testCase
    let sel = Selector((name))
    let block: @convention(block) () -> Void = block
    let imp = imp_implementationWithBlock(block)
    class_addMethod(cls, sel, imp, "d@:")
    return testCase.init(selector: sel)
}
