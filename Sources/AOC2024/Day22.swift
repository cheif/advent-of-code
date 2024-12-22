import Shared

private func part1(input: String) -> Int {
    let numbers = input.split(whereSeparator: \.isNewline).map { Int($0)! }
    let evolved = numbers.map { evolve(number: $0, iterations: 2_000) }
    return evolved.sum
}

private func part2(input: String) -> Int {
    let numbers = input.split(whereSeparator: \.isNewline).map { Int($0)! }
    //let numbers = [123]
    let evolutions = numbers.map { num in
        (0..<2000).reductions(num) { n, _ in evolve(number: n, iterations: 1) }
    }
    let prices = evolutions.map { evl in 
        evl.map { $0 % 10 }
    }
    let withChanges = prices.map { evl in 
        evl.indices.dropFirst(4).map { index in 
            let changes = [
                evl[index-3] - evl[index-4],
                evl[index-2] - evl[index-3],
                evl[index-1] - evl[index-2],
                evl[index] - evl[index-1]
            ]
            return (changes: changes, evl[index])
        }
    }
    let indexed = withChanges.map { wc in 
        wc.grouped(by: \.changes).mapValues { v in 
            v.first!.1
        }
    }

    let possibleChanges = (0..<4).reduce([[]]) {acc, _ -> [[Int]] in 
        (-9...9).flatMap { new in 
            acc.map {
                $0 + [new]
            }
        }
    }
    print(possibleChanges.count)
    print(withChanges.count)
    let scores = possibleChanges.enumerated().map { idx, changes in
        if idx % 1000 == 0 {
            print("at", idx)
        }
        return indexed.map { wc in 
            wc[changes] ?? 0
        }.sum
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
    n % 16777216
}

public let day22 = Solution(
    name: "day22",
    part1: part1,
    part2: part2
)
