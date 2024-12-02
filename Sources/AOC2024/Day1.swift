import Shared

private func part1(input: String) -> Int {
    let lines = input.split(whereSeparator: \.isNewline)
    let rows = lines.map { line in
        line.split(separator: "   ").map { Int($0)! }
    }
    let lhs = rows.map { $0[0] }
    let rhs = rows.map { $0[1] }
    let diffs = zip(lhs.sorted(), rhs.sorted()).map { abs($0 - $1) }
    return diffs.sum
}

private func part2(input: String) -> Int {
    let lines = input.split(whereSeparator: \.isNewline)
    let rows = lines.map { line in
        line.split(separator: "   ").map { Int($0)! }
    }
    let lhs = rows.map { $0[0] }
    let rhs = rows.map { $0[1] }
    let simScores = lhs.map { num in
        rhs.filter { $0 == num }.count * num
    }
    return simScores.sum
}

public let day1 = Solution(
    name: "day1",
    part1: part1,
    part2: part2
)
