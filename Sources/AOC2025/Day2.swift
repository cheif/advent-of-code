import Algorithms
import Shared

private func part1(input: String) -> Int {
    let ranges = parseRanges(input: input)
    let ids = ranges.flatMap { $0 }
    let invalid = ids.filter { id in
        let s = String(id)
        if s.count.remainderReportingOverflow(dividingBy: 2).partialValue == 0 {
            let lhs = s.prefix(s.count / 2)
            let rhs = s.suffix(s.count / 2)
            return lhs == rhs
        }
        return false
    }
    return invalid.reduce(0, +)
}

private func part2(input: String) -> Int {
    let ranges = parseRanges(input: input)
    let ids = ranges.flatMap { $0 }
    let invalid = ids.filter { id in
        let s = String(id)
        let potentialChunkSizes = (1...s.count).dropFirst()
            .filter { s.count.remainderReportingOverflow(dividingBy: $0).partialValue == 0 }
            .map { s.count / $0 }
        return potentialChunkSizes.contains { chunkSize in
            let chunks = s.chunked(into: chunkSize)
            return chunks.allSatisfy { $0 == chunks.first }
        }
    }
    return invalid.reduce(0, +)
}

private func parseRanges(input: String) -> [ClosedRange<Int>] {
    return input.trimming(while: \.isNewline).split(separator: ",").map { r in
        let s = r.split(separator: "-")
        return Int(s[0])!...Int(s[1])!
    }
}

public let day2 = Solution(
    name: "day2",
    part1: part1,
    part2: part2
)
