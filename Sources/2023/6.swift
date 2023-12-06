import Foundation
import Shared

func parse(input: String) -> [(Int, Int)] {
    let split = input.split(whereSeparator: \.isNewline)
        .map { $0.split(whereSeparator: \.isWhitespace).dropFirst().map { Int($0)! }}
    return Array(zip(split[0], split[1]))
}

public let day6 = Solution(
    part1: { input in
        let races = parse(input: input)
        let solutions = races.map { (time, distance) in
            (0..<time).map { held in
                return ((time - held) * held) > distance
            }
        }
        let wins = solutions.map { $0.filter { $0 }.count }
        return wins.reduce(1, *)
    },
    part2: { input in
        let rInp = input.split(whereSeparator: \.isNewline)
            .map { Int($0.split(whereSeparator: \.isWhitespace).dropFirst().joined())! }
        let (time, distance) = (rInp[0], rInp[1])
        let solutions = (0..<time).map { held in ((time - held) * held) > distance }
        let wins = solutions.filter { $0 }.count
        return wins
    },
    testResult: (288, 71503),
    testInput: """
Time:      7  15   30
Distance:  9  40  200
""",
    input: """
Time:        47     84     74     67
Distance:   207   1394   1209   1014
"""
)
