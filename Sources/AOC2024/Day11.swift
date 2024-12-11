import Shared

private func part1(input: String) -> Int {
    let stones = input.split(separator: " ").map { Int(String($0))! }
    return stones
        .map { stone in resultingStones(stone: stone, iterations: 25) }
        .sum
}

private func part2(input: String) -> Int {
    let stones = input.split(separator: " ").map { Int(String($0))! }
    return stones
        .map { stone in resultingStones(stone: stone, iterations: 75) }
        .sum
}

private func resultingStones(stone: Int, iterations: Int) -> Int {
    var cache: [Int: [Int: Int]] = [:]

    func run(stone: Int, iterations: Int) -> Int {
        if let res = cache[stone, default: [:]][iterations] {
            return res
        }
        guard iterations > 0 else {
            return 1
        }
        let res = newStones(stone: stone).map { stone in
            run(stone: stone, iterations: iterations - 1)
        }.sum

        cache[stone, default: [:]][iterations] = res

        return res
    }

    return run(stone: stone, iterations: iterations)
}


private func newStones(stone: Int) -> [Int] {
    let str = String(stone)
    if stone == 0 {
        return [1]
    } else if str.count % 2 == 0 {
        return [Int(str.prefix(str.count / 2))!, Int(str.dropFirst(str.count/2))!]
    } else {
        return [stone * 2024]
    }
}


public let day11 = Solution(
    name: "day11",
    part1: part1,
    part2: part2
)
