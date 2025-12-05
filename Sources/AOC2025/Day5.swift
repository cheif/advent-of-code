import Algorithms
import Shared

private func part1(input: String) -> Int {
    let splits = input.split(separator: "\n\n")
    let fresh = splits[0].split(whereSeparator: \.isNewline).map { ClosedRange($0)! }
    let available = splits[1].split(whereSeparator: \.isNewline).map { Int($0)! }
    return available.filter { i in fresh.contains { $0.contains(i) } }.count
}

private func part2(input: String) -> Int {
    let splits = input.split(separator: "\n\n")
    let fresh = splits[0].split(whereSeparator: \.isNewline).map { ClosedRange($0)! }
    let freshCompressed = fresh.mergeOverlapping()
    // 305571785333839 not correct
    // 304153593779180 not correct
    // 357949154866363
    return freshCompressed.map(\.count).sum
}

public let day5 = Solution(
    name: "day5",
    part1: part1,
    part2: part2
)
