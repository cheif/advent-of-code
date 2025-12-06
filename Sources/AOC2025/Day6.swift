import Algorithms
import Shared

private func part1(input: String) -> Int {
    let items = input.split(whereSeparator: \.isNewline).map {
        $0.split(whereSeparator: \.isWhitespace)
    }
    let totals = items[0].indices.map { i in
        let data = items.map { $0[i] }
        let numbers = data.dropLast().map { Int(String($0))! }
        let op = data.last!
        switch op {
        case "*":
            return numbers.reduce(1, *)
        case "+":
            return numbers.reduce(0, +)
        default:
            fatalError()
        }
    }
    return totals.sum
}

private func part2(input: String) -> Int {
    let lines = input.split(separator: "\n").map { String($0) }
    var numbers: [[Int]] = [[]]
    for i in lines[0].indices.reversed() {
        let candidate = lines.dropLast().map { String($0[i]) }.joined().trimmingCharacters(
            in: .whitespaces)
        if let num = Int(candidate) {
            numbers[numbers.count - 1].append(num)
        } else {
            numbers.append([])
        }
    }
    let operands = lines.last!.split(whereSeparator: \.isWhitespace).reversed()
    let totals = zip(operands, numbers).map { op, numbers in
        switch op {
        case "*":
            return numbers.reduce(1, *)
        case "+":
            return numbers.reduce(0, +)
        default:
            fatalError()
        }
    }
    return totals.sum
}

public let day6 = Solution(
    name: "day6",
    part1: part1,
    part2: part2
)
