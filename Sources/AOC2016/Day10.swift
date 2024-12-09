import Shared

private func part1(input: String) -> Int {
    let (start, rules) = parse(input: input)
    var passthrough: [Int: Set<Int>] = [:]
    var iter = [start]
    while true {
        let last = iter.last!
        for (bot, values) in last {
            passthrough[bot] = (passthrough[bot] ?? Set()).union(values)
        }

        let hasTwo = last.filter { $0.value.count == 2 }
        guard !hasTwo.isEmpty else { break }
        var next = iter.last!
        for (bot, values) in hasTwo {
            let rule = rules.first { $0.bot == bot }!
            next[bot] = []
            if let high = rule.high {
                next[high] = (next[high] ?? []) + [values.max()!]
            }
            if let low = rule.low {
                next[low] = (next[low] ?? []) + [values.min()!]
            }
        }
        iter.append(next)

    }
    let toSearch = input.split(whereSeparator: \.isNewline).count < 10 ? Set([2, 5]) : Set([17, 61])
    return passthrough.first { bot in toSearch.allSatisfy { bot.value.contains($0) }}!.key
}

private func part2(input: String) -> Int {
    let (start, rules) = parse(input: input)
    var outputs: [Int: [Int]] = [:]
    var iter = [start]
    while true {
        let last = iter.last!
        let hasTwo = last.filter { $0.value.count == 2 }
        guard !hasTwo.isEmpty else { break }
        var next = iter.last!
        for (bot, values) in hasTwo {
            let rule = rules.first { $0.bot == bot }!
            next[bot] = []
            if let high = rule.high {
                next[high] = (next[high] ?? []) + [values.max()!]
            } else if let high = rule.highOutput {
                outputs[high] = (outputs[high] ?? []) + [values.max()!]
            }
            if let low = rule.low {
                next[low] = (next[low] ?? []) + [values.min()!]
            } else if let low = rule.lowOutput {
                outputs[low] = (outputs[low] ?? []) + [values.min()!]
            }
        }
        iter.append(next)

    }
    return outputs.filter { $0.key <= 2 }.compactMap(\.value.first).reduce(1, *)
}

private typealias Rule = (bot: Int, low: Int?, high: Int?, lowOutput: Int?, highOutput: Int?)
private func parse(input: String) -> ([Int: [Int]], [Rule]) {
    let lines = input.split(whereSeparator: \.isNewline)
    let start = lines
        .filter { $0.starts(with: "value") }
        .map { line in
            let split = line.split(separator: " goes to bot ")
            return (
                value: Int(split[0].split(separator: " ")[1])!,
                bot: Int(split[1])!
            )
        }
        .grouped(by: \.bot)
        .mapValues { $0.map(\.value) }
    let rules = lines
        .filter { $0.starts(with: "bot ") }
        .map { line in
            let nums = line.split(separator: " ").compactMap { Int($0) }
            let lowBot = line.contains("low to bot")
            let highBot = line.contains("high to bot")
            return (
                bot: nums[0],
                low: lowBot ? nums[1] : nil,
                high: highBot ? nums[2] : nil,
                lowOutput: lowBot ? nil : nums[1],
                highOutput: highBot ? nil : nums[2]
            )
        }
    return (start, rules)
}

public let day10 = Solution(
    name: "day10",
    part1: part1,
    part2: part2
)
