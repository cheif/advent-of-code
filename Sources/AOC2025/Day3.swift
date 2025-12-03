import Algorithms
import Foundation
import Shared

private func part1(input: String) -> Int {
    solve(input: input, batteries: 2)
}

private func part2(input: String) -> Int {
    solve(input: input, batteries: 12)
}

private func solve(input: String, batteries: Int) -> Int {
    input.split(whereSeparator: \.isNewline)
        .map { bank in bank.map { Int(String($0))! } }
        .map { bank in findBiggestJoltage(bank: bank, batteries: batteries) }
        .sum
}

private func findBiggestJoltage(bank: [Int], batteries: Int) -> Int {
    guard batteries > 0 else { return 0 }
    let biggest = bank.dropLast(batteries - 1).max()!
    let joltage = biggest * (pow(10, batteries - 1) as NSDecimalNumber).intValue

    let offset = bank.firstIndex(of: biggest)! + 1
    let remainingJoltage = findBiggestJoltage(
        bank: Array(bank.dropFirst(offset)),
        batteries: batteries - 1
    )
    return joltage + remainingJoltage
}

public let day3 = Solution(
    name: "day3",
    part1: part1,
    part2: part2
)
