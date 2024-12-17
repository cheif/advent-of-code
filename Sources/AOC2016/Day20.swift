import Algorithms
import Shared

private func part1(input: String) -> Int {
    let validRanges = validRanges(input: input)
    return validRanges.map(\.lowerBound).min()!
}

private func part2(input: String) -> Int {
    let validRanges = validRanges(input: input)
    // 1 is incorrect
    return validRanges.map(\.count).sum
}

private func validRanges(input: String) -> [Range<Int>] {
    let lines = input.split(whereSeparator: \.isNewline)
    let invalidRanges = lines.map { line in 
        let s = line.split(separator: "-").map { Int($0)! }
        return s[0]..<(s[1]+1)
    }
    let upperBound = lines.count > 10 ? 4294967295 : 9
    let fullRange = 0..<(upperBound+1)
    let validRanges = invalidRanges.reduce([fullRange]) { validRanges, invalid in
        validRanges.flatMap { range in 
            range.difference(from: invalid)
        }
    }
    return validRanges
}

public let day20 = Solution(
    name: "day20",
    part1: part1,
    part2: part2
)
