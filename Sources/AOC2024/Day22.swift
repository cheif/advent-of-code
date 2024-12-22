import Shared

private func part1(input: String) -> Int {
    let numbers = input.split(whereSeparator: \.isNewline).map { Int($0)! }
    let evolved = numbers.map { evolve(number: $0, iterations: 2_000) }
    return evolved.sum
}

private func part2(input: String) -> Int {
    let numbers = input.split(whereSeparator: \.isNewline).map { Int($0)! }
    let evolutions = numbers.map { num in
        (0..<2000).reductions(num) { n, _ in evolve(number: n, iterations: 1) }
    }
    let prices = evolutions.map { evl in
        evl.map { $0 % 10 }
    }

    var indexed: [[Int]: [Int: Int]] = [:]
    for (pIndex, evl) in prices.enumerated() {
        for index in evl.indices.dropFirst(4) {
            let changes = [
                evl[index - 3] - evl[index - 4],
                evl[index - 2] - evl[index - 3],
                evl[index - 1] - evl[index - 2],
                evl[index] - evl[index - 1],
            ]
            if indexed[changes] == nil {
                indexed[changes] = [:]
            }
            if indexed[changes]![pIndex] == nil {
                indexed[changes]![pIndex] = evl[index]
            }
        }
    }

    let possibleChanges = (0..<4).reduce([[]]) { acc, _ -> [[Int]] in
        (-9...9).flatMap { new in
            acc.map {
                $0 + [new]
            }
        }
    }
    let scores = possibleChanges.enumerated().map { idx, changes in
        return indexed[changes, default: [:]].values.sum
    }
    return scores.max()!
}

private func evolve(number: Int, iterations: Int) -> Int {
    if iterations == 0 {
        return number
    }
    var number = number
    let mul = number * 64
    number = prune(mix(a: number, b: mul))
    let div = number / 32
    number = prune(mix(a: number, b: div))
    let mul2 = number * 2048
    number = prune(mix(a: number, b: mul2))
    return evolve(number: number, iterations: iterations - 1)
}

private func mix(a: Int, b: Int) -> Int {
    a ^ b
}

private func prune(_ n: Int) -> Int {
    n % 16_777_216
}

public let day22 = Solution(
    name: "day22",
    part1: part1,
    part2: part2
)
