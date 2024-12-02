import Shared

private func part1(input: String) -> Int {
    let levels = input.split(whereSeparator: \.isNewline).map { $0.split(separator: " ").map { Int($0)! }}
    let safe = levels.filter(isSafe(levels:))
    return safe.count
}

private func part2(input: String) -> Int {
    let levels = input.split(whereSeparator: \.isNewline).map { $0.split(separator: " ").map { Int($0)! }}
    let safe = levels.filter { levels in
        return isSafe(levels: levels) ||
        levels.indices.contains(where: { idx in
            let fixed = levels.prefix(upTo: idx) + levels.suffix(from: idx + 1)
            return isSafe(levels: Array(fixed))
        })
    }
    return safe.count
}

func isSafe(levels: [Int]) -> Bool {
    let sorted = levels.sorted() == levels || levels.sorted().reversed() == levels
    let diffs = zip(levels, levels.dropFirst()).map { abs($0 - $1) }.allSatisfy { 1 <= $0 && $0 <= 3 }
    return sorted && diffs
}

public let day2 = Solution(
    name: "day2",
    part1: part1,
    part2: part2
)

