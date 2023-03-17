import Foundation

// FIXME: Use UTC calendar?
let day: Int = CommandLine.arguments.dropFirst().first.flatMap { Int($0) } ?? Calendar.current.component(.day, from: Date())

let solutions: [Int: () -> Void] = [
    1: day1,
    2: day2,
    3: day3,
    4: day4,
    5: day5,
    6: day6,
    7: day7,
    8: day8,
    9: day9,
    10: day10,
    11: day11,
    12: day12,
    13: day13,
    14: day14,
    15: day15,
    16: day16,
    17: day17,
    18: day18,
    19: day19,
    20: day20,
    21: day21,
    22: day22,
    23: day23,
    24: day24,
    25: day25
]
guard let solution = solutions[day] else {
    fatalError("No solution for \(day)")
}
print("Running solution for day: \(day)")
let duration = ContinuousClock().measure {
    solution()
}

print("Took: \(duration)")

