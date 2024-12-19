import Shared

private func part1(input: String) -> Int {
    let lines = input.split(whereSeparator: \.isNewline)
    let patterns = Set(lines[0].split(separator: ", ").map { String($0) })
    let designs = lines.dropFirst(1).map { String($0) }
    let lengths = Set(patterns.map(\.count))
    let tester = Tester(patterns: patterns, lengths: lengths)
    let possible = designs.enumerated().filter { idx, d in 
        tester.possibilities(design: d) > 0
    }
    return possible.count
}

private func part2(input: String) -> Int {
    let lines = input.split(whereSeparator: \.isNewline)
    let patterns = Set(lines[0].split(separator: ", ").map { String($0) })
    let designs = lines.dropFirst(1).map { String($0) }
    let lengths = Set(patterns.map(\.count))
    let tester = Tester(patterns: patterns, lengths: lengths)
    let allPossibilities = designs.enumerated().map { idx, d in 
        tester.possibilities(design: d)
    }
    // 5172855115202853 is incorrect
    return allPossibilities.sum
}

private class Tester {
    let patterns: Set<String>
    let lengths: Set<Int>

    init(patterns: Set<String>, lengths: Set<Int>) {
        self.patterns = patterns
        self.lengths = lengths
    }
    private var cache: [String: Int] = [:]

    func possibilities(design: String) -> Int {
        if let v = cache[design] {
            return v
        }
        if design.isEmpty {
            return 1
        }
        let starts = Set(
            lengths
                .map { l in String(design.prefix(l)) }
                .filter(patterns.contains)
        )

        let possibleStarts = starts.map { s in
            self.possibilities(design: String(design.dropFirst(s.count)))
        }
        let res = possibleStarts.sum
        cache[design] = res
        return res
    }
}


public let day19 = Solution(
    name: "day19",
    part1: part1,
    part2: part2
)
