import Foundation
import Shared
import AOC2022
import AOC2023

// FIXME: Use UTC calendar?
let year: Int = CommandLine.arguments.dropFirst().first.flatMap { Int($0) } ?? Calendar.current.component(.year, from: Date())
let day: Int = CommandLine.arguments.dropFirst(2).first.flatMap { Int($0) } ?? Calendar.current.component(.day, from: Date())

guard let solution = solution(year: year, day: day) else {
    fatalError("No solution for \(year)-\(day)")
}
print("Running solution for \(year)-\(day)")
let duration = ContinuousClock().measure {
    print("part 1: \(solution.part1(input: solution.input))")
    print("part 2: \(solution.part2(input: solution.input))")
}

print("Took: \(duration)")

public func solution(year: Int, day: Int) -> (any SolutionProtocol)? {
    switch (year, day) {
    case (2022, 1): return AOC2022.day1
    case (2022, 2): return LegacySolution(AOC2022.day2)
    case (2022, 3): return LegacySolution(AOC2022.day3)
    case (2022, 4): return LegacySolution(AOC2022.day4)
    case (2022, 5): return LegacySolution(AOC2022.day5)
    case (2022, 6): return LegacySolution(AOC2022.day6)
    case (2022, 7): return LegacySolution(AOC2022.day7)
    case (2022, 8): return LegacySolution(AOC2022.day8)
    case (2022, 9): return LegacySolution(AOC2022.day9)
    case (2022, 10): return LegacySolution(AOC2022.day10)
    case (2022, 11): return LegacySolution(AOC2022.day11)
    case (2022, 12): return LegacySolution(AOC2022.day12)
    case (2022, 13): return LegacySolution(AOC2022.day13)
    case (2022, 14): return LegacySolution(AOC2022.day14)
    case (2022, 15): return LegacySolution(AOC2022.day15)
    case (2022, 16): return LegacySolution(AOC2022.day16)
    case (2022, 17): return LegacySolution(AOC2022.day17)
    case (2022, 18): return LegacySolution(AOC2022.day18)
    case (2022, 19): return LegacySolution(AOC2022.day19)
    case (2022, 20): return LegacySolution(AOC2022.day20)
    case (2022, 21): return LegacySolution(AOC2022.day21)
    case (2022, 22): return LegacySolution(AOC2022.day22)
    case (2022, 23): return LegacySolution(AOC2022.day23)
    case (2022, 24): return LegacySolution(AOC2022.day24)
    case (2022, 25): return LegacySolution(AOC2022.day25)
    case (2023, 1): return AOC2023.day1
    case (2023, 2): return AOC2023.day2
    case (2023, 3): return AOC2023.day3
    case (2023, 4): return AOC2023.day4
    case (2023, 5): return AOC2023.day5
    case (2023, 6): return AOC2023.day6
    case (2023, 7): return AOC2023.day7
    default: return nil
    }
}

struct LegacySolution: SolutionProtocol {
    func part1(input: String) -> Int {
        if input == testInput {
            return testResult.0
        }
        run()
        return 0
    }

    func part2(input: String) -> Int {
        if input == testInput {
            return testResult.1
        }
        return 0
    }

    let testInput = ""
    let part2TestInput: String? = nil
    let testResult = (0, 0)
    let input = ""

    let run: () -> Void
    init(_ run: @escaping () -> Void) {
        self.run = run
    }
}
