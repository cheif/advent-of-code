import Algorithms
import Shared

private func part1(input: String) -> Int {
    let eqs = input.split(whereSeparator: \.isNewline).map { line in
        let split = line.split(separator: ":")
        return (test: Int(String(split[0]))!, nums: split[1].split(separator: " ").map { Int(String($0))! })
    }
    let canBeMadeTrue = eqs.filter { eq in
        eq.nums.dropFirst()
            .reduce(Array(eq.nums.prefix(1))) { partialResult, num -> [Int] in
                partialResult.flatMap { r in
                    let mul = r * num
                    let add = r + num
                    return [mul, add]
                }.filter { $0 <= eq.test}
            }
        .contains(where: { $0 == eq.test})
    }
    return canBeMadeTrue.map(\.test).sum
}

private func part2(input: String) -> Int {
    let eqs = input.split(whereSeparator: \.isNewline).map { line in
        let split = line.split(separator: ":")
        return (test: Int(String(split[0]))!, nums: split[1].split(separator: " ").map { Int(String($0))! })
    }
    let canBeMadeTrue = eqs.filter { eq in
        eq.nums.dropFirst()
            .reduce(Array(eq.nums.prefix(1))) { partialResult, num -> [Int] in
                partialResult.flatMap { r in
                    let mul = r * num
                    let add = r + num
                    let concat = Int(String(r) + String(num))!
                    return [mul, add, concat]
                }.filter { $0 <= eq.test}
            }
        .contains(where: { $0 == eq.test})
    }
    return canBeMadeTrue.map(\.test).sum
}
public let day7 = Solution(
    name: "day7",
    part1: part1,
    part2: part2
)

