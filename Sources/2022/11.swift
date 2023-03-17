import Shared

public func day11() {
//    print(part1(input: input))
    print(part2(input: input))
}

private func part1(input: String) -> Int {
    let monkeys = parse(input)
    let result = (0..<20).reduce(monkeys) { prev, _ in simulateRound(start: prev) }
    return result.map(\.inspectedItems).sorted().suffix(2).reduce(1, *)
}

private func part2(input: String) -> Int {
    let monkeys = parse(input)
    let result = (0..<10000).reduce(monkeys) { prev, _ in simulateRoundPart2(start: prev) }
    print(result.map(\.inspectedItems))
    return result.map(\.inspectedItems).sorted().suffix(2).reduce(1, *)
}

private func simulateRound(start: [Monkey]) -> [Monkey] {
    var monkeys: [Monkey] = start
    for index in monkeys.indices {
        let monkey = monkeys[index]
        monkey.items.forEach { item in
            let new = Int((Double(monkey.operation(item)) / 3.0).rounded(.down))
            let to = monkey.throwTo(new)
            let toIndex = monkeys.firstIndex(where: { $0.id == to })!
            monkeys[toIndex].items.append(new)
        }
        monkeys[index].inspectedItems += monkey.items.count
        monkeys[index].items = []
    }
    return monkeys
}

private func simulateRoundPart2(start: [Monkey]) -> [Monkey] {
    var monkeys: [Monkey] = start
    let upperBound = monkeys.map(\.divisor).reduce(1, *)
    for index in monkeys.indices {
        let monkey = monkeys[index]
        monkey.items.forEach { item in
            let new = monkey.operation(item) % upperBound
            let to = monkey.throwTo(new)
            let toIndex = monkeys.firstIndex(where: { $0.id == to })!
            monkeys[toIndex].items.append(new)
        }
        monkeys[index].inspectedItems += monkey.items.count
        monkeys[index].items = []
    }
    return monkeys
}

private struct Monkey: CustomDebugStringConvertible {
    let id: Int
    var items: [Int]
    var inspectedItems = 0
    let operation: (Int) -> Int
    let divisor: Int
    let trueMonkey: Int
    let falseMonkey: Int

    func throwTo(_ worry: Int) -> Int {
        worry % divisor == 0 ? trueMonkey : falseMonkey
    }

    var debugDescription: String {
        "Monkey \(id): \(items)"
    }
}

private func parse(_ input: String) -> [Monkey] {
    let groups = input.split(separator: "\n\n")
    return groups.map { input in
        let lines = input.split(whereSeparator: \.isNewline)
        let id = Int(lines[0].dropFirst(7).dropLast())!
        let items = lines[1].split(separator: ": ")[1].split(separator: ", ").map(String.init).compactMap(Int.init)
        let operationParts = lines[2].split(separator: "new = old ")[1].split(whereSeparator: \.isWhitespace)
        let operation: (Int) -> Int
        if let other = Int(operationParts[1]) {
            if operationParts[0] == "+" {
                operation = { $0 + other }
            } else {
                operation = { $0 * other }
            }
        } else {
            if operationParts[0] == "+" {
                operation = { $0 + $0 }
            } else {
                operation = { $0 * $0 }
            }
        }
        let divisor = Int(lines[3].split(separator: "divisible by ")[1])!
        let trueMonkey = Int(lines[4].split(separator: "monkey ")[1])!
        let falseMonkey = Int(lines[5].split(separator: "monkey ")[1])!
        return Monkey(
            id: id,
            items: items,
            operation: operation,
            divisor: divisor,
            trueMonkey: trueMonkey,
            falseMonkey: falseMonkey
        )
    }
    .sorted(by: { $0.id < $1.id })
}

private let test = """
Monkey 0:
  Starting items: 79, 98
  Operation: new = old * 19
  Test: divisible by 23
    If true: throw to monkey 2
    If false: throw to monkey 3

Monkey 1:
  Starting items: 54, 65, 75, 74
  Operation: new = old + 6
  Test: divisible by 19
    If true: throw to monkey 2
    If false: throw to monkey 0

Monkey 2:
  Starting items: 79, 60, 97
  Operation: new = old * old
  Test: divisible by 13
    If true: throw to monkey 1
    If false: throw to monkey 3

Monkey 3:
  Starting items: 74
  Operation: new = old + 3
  Test: divisible by 17
    If true: throw to monkey 0
    If false: throw to monkey 1
"""

private let input = """
Monkey 0:
  Starting items: 64, 89, 65, 95
  Operation: new = old * 7
  Test: divisible by 3
    If true: throw to monkey 4
    If false: throw to monkey 1

Monkey 1:
  Starting items: 76, 66, 74, 87, 70, 56, 51, 66
  Operation: new = old + 5
  Test: divisible by 13
    If true: throw to monkey 7
    If false: throw to monkey 3

Monkey 2:
  Starting items: 91, 60, 63
  Operation: new = old * old
  Test: divisible by 2
    If true: throw to monkey 6
    If false: throw to monkey 5

Monkey 3:
  Starting items: 92, 61, 79, 97, 79
  Operation: new = old + 6
  Test: divisible by 11
    If true: throw to monkey 2
    If false: throw to monkey 6

Monkey 4:
  Starting items: 93, 54
  Operation: new = old * 11
  Test: divisible by 5
    If true: throw to monkey 1
    If false: throw to monkey 7

Monkey 5:
  Starting items: 60, 79, 92, 69, 88, 82, 70
  Operation: new = old + 8
  Test: divisible by 17
    If true: throw to monkey 4
    If false: throw to monkey 0

Monkey 6:
  Starting items: 64, 57, 73, 89, 55, 53
  Operation: new = old + 1
  Test: divisible by 19
    If true: throw to monkey 0
    If false: throw to monkey 5

Monkey 7:
  Starting items: 62
  Operation: new = old + 4
  Test: divisible by 7
    If true: throw to monkey 3
    If false: throw to monkey 2
"""
