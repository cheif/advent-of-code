import Shared

private func part1(input: String) -> Int {
    let regex = try! Regex("mul\\(([0-9]{1,3}),([0-9]{1,3})\\)")
    let muls = input.matches(of: regex).map { match in
        return Int(match[1].value! as! Substring)! * Int(match[2].value! as! Substring)!
    }
    return muls.sum
}

private func part2(input: String) -> Int {
    let parts = input.split(separator: "don't()").map { String($0) }
    let afterDo = parts.dropFirst().map { part in
        part.split(separator: "do()").dropFirst().joined(separator: "")
    }
    let filtered = (parts.prefix(1) + afterDo).joined(separator: "")
    return part1(input: filtered)
}

public let day3 = Solution(
    name: "day3",
    part1: part1,
    part2: part2
)
