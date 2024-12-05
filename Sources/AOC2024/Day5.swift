import Algorithms
import Shared

private func part1(input: String) -> Int {
    let (rules, updates) = parse(input: input)
    let valid = updates.filter { isValid(update: $0, rules: rules) }
    let middleNumbers = valid.map { $0[$0.count / 2] }
    return middleNumbers.sum
}

private func part2(input: String) -> Int {
    let (rules, updates) = parse(input: input)
    let invalid = updates.filter { !isValid(update: $0, rules: rules) }
    let fixed = invalid.map { fix(update: $0, rules: rules) }
    let middleNumbers = fixed.map { $0[$0.count / 2] }
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

private func isValid(update: [Int], rules: [(Int, Int)]) -> Bool {
    for i in update.indices {
        let num = update[i]
        let after = rules.filter { $0.0 == num }.map(\.1)
        let before = rules.filter { $0.1 == num }.map(\.0)
        if update.prefix(upTo: i).contains(where: { after.contains($0) }) ||
            update.suffix(from: i).contains(where: { before.contains($0) }) {
            return false
        }
    }
    return true
}

private func fix(update: [Int], rules: [(Int, Int)]) -> [Int] {
    guard !update.isEmpty else { return [] }
    // Find the first one using the rules, and then just fix it recursively
    let first = update.first(where: { num in
        let other = update.filter { $0 != num }
        let before = rules.filter { $0.1 == num }.map(\.0).filter { other.contains($0) }
        return before.count == 0
    })
    return [first!] + fix(update: update.filter { $0 != first }, rules: rules)
}

public let day5 = Solution(
    name: "day5",
    part1: part1,
    part2: part2
)
