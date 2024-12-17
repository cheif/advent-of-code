import Shared

private func part1(input: String) -> Int {
    let bools: [Bool] = input.map { $0 == "^" }
    // 4980 is too high
    return expandAndCount(input: bools, rows: min(input.count, 40))
}

private func part2(input: String) -> Int {
    let bools: [Bool] = input.map { $0 == "^" }
    // 20013301 is too high
    return expandAndCount(input: bools, rows: 400_000)
}

private func expandAndCount(input: [Bool], rows: Int) -> Int {
    var row = input
    var count = row.filter { !$0 }.count
    for _ in (1..<rows) {
        row = row.indices.map { x -> Bool in
            let left = row[safe: x - 1] ?? false
            let center = row[x]
            let right = row[safe: x + 1] ?? false
            let hasTrap =
                (left && center && !right) || (!left && center && right)
                || (left && !center && !right) || (!left && !center && right)
            return hasTrap
        }
        count += row.filter { !$0 }.count
    }
    return count
}

public let day18 = Solution(
    name: "day18",
    part1: part1,
    part2: part2
)
