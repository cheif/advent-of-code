import Foundation
import AOC2022

// FIXME: Use UTC calendar?
let year: Int = CommandLine.arguments.dropFirst().first.flatMap { Int($0) } ?? Calendar.current.component(.year, from: Date())
let day: Int = CommandLine.arguments.dropFirst(2).first.flatMap { Int($0) } ?? Calendar.current.component(.day, from: Date())

guard let solution = solution(year: year, day: day) else {
    fatalError("No solution for \(year)-\(day)")
}
print("Running solution for \(year)\\(day)")
let duration = ContinuousClock().measure {
    solution()
}

print("Took: \(duration)")

private func solution(year: Int, day: Int) -> (() -> Void)? {
    switch (year, day) {
    case (2022, 1): return AOC2022.day1
    case (2022, 2): return AOC2022.day2
    case (2022, 3): return AOC2022.day3
    case (2022, 4): return AOC2022.day4
    case (2022, 5): return AOC2022.day5
    case (2022, 6): return AOC2022.day6
    case (2022, 7): return AOC2022.day7
    case (2022, 8): return AOC2022.day8
    case (2022, 9): return AOC2022.day9
    case (2022, 10): return AOC2022.day10
    case (2022, 11): return AOC2022.day11
    case (2022, 12): return AOC2022.day12
    case (2022, 13): return AOC2022.day13
    case (2022, 14): return AOC2022.day14
    case (2022, 15): return AOC2022.day15
    case (2022, 16): return AOC2022.day16
    case (2022, 17): return AOC2022.day17
    case (2022, 18): return AOC2022.day18
    case (2022, 19): return AOC2022.day19
    case (2022, 20): return AOC2022.day20
    case (2022, 21): return AOC2022.day21
    case (2022, 22): return AOC2022.day22
    case (2022, 23): return AOC2022.day23
    case (2022, 24): return AOC2022.day24
    case (2022, 25): return AOC2022.day25
    default: return nil
    }
}
