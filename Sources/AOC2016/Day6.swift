import Shared

private func part1(input: String) -> String {
    let lines = input.split(whereSeparator: \.isNewline).map { line in line.map { $0 }}
    let corrected = (0..<lines.first!.count).map { idx -> Character in
        let letters = lines.map { $0[idx] }.grouped(by: \.self).mapValues(\.count)
        return letters.max(by: { $0.value < $1.value })!.key
    }
    return String(corrected)
}

private func part2(input: String) -> String {
    let lines = input.split(whereSeparator: \.isNewline).map { line in line.map { $0 }}
    let corrected = (0..<lines.first!.count).map { idx -> Character in
        let letters = lines.map { $0[idx] }.grouped(by: \.self).mapValues(\.count)
        return letters.min(by: { $0.value < $1.value })!.key
    }
    return String(corrected)
}

public let day6 = Solution(
    name: "day6",
    part1: part1,
    part2: part2
)
