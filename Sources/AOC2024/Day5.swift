import Algorithms
import Shared

private func part1(input: String) -> Int {
    let (rules, updates) = parse(input: input)
    let withSorted = updates.map { ($0, sorted(update: $0, rules: rules) )}
    let valid = withSorted.filter { $0 == $1 }.map(\.1)
    let middleNumbers = valid.map { $0[$0.count / 2] }
    return middleNumbers.sum
}

private func part2(input: String) -> Int {
    let (rules, updates) = parse(input: input)
    let withSorted = updates.map { ($0, sorted(update: $0, rules: rules) )}
    let valid = withSorted.filter { $0 != $1 }.map(\.1)
    let middleNumbers = valid.map { $0[$0.count / 2] }
    return middleNumbers.sum
}

private func parse(input: String) -> ([(Int, Int)], [[Int]]) {
    let splitted = input.split(separator: "\n\n")
    let rules = splitted[0].split(whereSeparator: \.isNewline).map { line in
        let split = line.split(separator: "|")
        return (Int(split[0])!, Int(split[1])!)
    }
    let updates = splitted[1].split(whereSeparator: \.isNewline).map { line in
        Array(line.split(separator: ",").map { Int($0)! })
    }
    return (rules, updates)
}

private func sorted(update: [Int], rules: [(Int, Int)]) -> [Int] {
    update.map { num in
        let other = update.filter { $0 != num }
        let before = rules.filter { $0.1 == num && other.contains($0.0) }.map(\.0)
        return (i: before.count, val: num)
    }.sorted(by: { $0.i < $1.i }).map(\.val)
}

public let day5 = Solution(
    name: "day5",
    part1: part1,
    part2: part2
)
