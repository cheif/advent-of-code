import Shared

private func part1(input: String) -> Int {
    let codes = input.split(whereSeparator: \.isNewline).map { String($0) }
    let calculator = PathCalculator(intermediateRobots: 2)
    let shortest = codes.map { code in (code, calculator.shortestSequence(code)) }
    let complexities = shortest.map { code, seq in
        Int(String(code.filter(\.isNumber)))! * seq
    }
    return complexities.sum
}

private func part2(input: String) -> Int {
    let codes = input.split(whereSeparator: \.isNewline).map { String($0) }
    let calculator = PathCalculator(intermediateRobots: 25)
    let shortest = codes.map { code in (code, calculator.shortestSequence(code)) }
    let complexities = shortest.map { code, seq in
        Int(String(code.filter(\.isNumber)))! * seq
    }
    return complexities.sum
}

private class PathCalculator {
    let numPad = Grid(string: numericPad)
    let dirPad = Grid(string: directionalPad)
    let intermediateRobots: Int
    init(intermediateRobots: Int) {
        self.intermediateRobots = intermediateRobots
    }

    func shortestSequence(_ code: String) -> Int {
        let numPadCandidates = numPad.shortest(code)
        let all =
            numPadCandidates
            .map { subPaths in
                subPaths.map { shortestCached(depth: 0, prev: $0) }.sum
            }
        return all.min()!
    }

    var cache: [Int: [Subpath: Int]] = [:]
    func shortestCached(depth: Int, prev: Subpath) -> Int {
        if let cached = cache[depth]?[prev] {
            return cached
        } else if depth == intermediateRobots {
            return len([prev])
        } else {
            let next = dirPad.shortest(string(prev))
            let res = next.map { path -> Int in
                path
                    .map { shortestCached(depth: depth + 1, prev: $0) }
                    .sum
            }
            .min()!
            cache[depth, default: [:]][prev] = res
            return res
        }
    }
}

typealias Subpath = [Direction]
typealias Path = [Subpath]
extension Grid where V == Character {
    fileprivate func shortest(_ code: String) -> [Path] {
        let start = self.data.first { $0.val == "A" }!
        var allPaths: [Path] = []
        for letter in code {
            let target = self.data.first { $0.val == letter }!
            if allPaths.isEmpty {
                let shortest = start.distance(to: target)
                allPaths = self.paths(to: target, from: start, maxLength: shortest)!.map { [$0] }
            } else {
                allPaths = allPaths.flatMap { path -> [Path] in
                    let start = path.reduce(start) { $0.move(in: $1) }
                    let shortest = start.distance(to: target)
                    if let subPaths = paths(to: target, from: start, maxLength: shortest) {
                        return subPaths.map { subPath in path + [subPath] }
                    } else {
                        return []
                    }
                }
            }
        }
        return allPaths
    }

    private func paths(
        to target: Point,
        from start: Point,
        maxLength: Int
    ) -> [Subpath]? {
        guard maxLength >= 0 else {
            return nil
        }
        if start.position == target.position {
            return [[]]
        } else {
            let neighbours = self.neighbours(to: start)
                .filter { $0.value.val != " " }
            return neighbours.flatMap { dir, pos in
                if let subPaths = self.paths(to: target, from: pos, maxLength: maxLength - 1) {
                    return subPaths.map { [dir] + $0 }
                } else {
                    return []
                }
            }
        }
    }

}

private func len(_ path: Path) -> Int {
    path.map(\.count).sum + path.count
}

private func string(_ path: Path) -> String {
    path.compactMap { (subpath: Subpath) -> String in string(subpath) }.joined()
}

private func string(_ subPath: Subpath) -> String {
    (subPath.map(\.dirLetter) + ["A"]).joined()
}

extension Direction {
    fileprivate var dirLetter: String {
        return switch self {
        case .up: "^"
        case .left: "<"
        case .down: "v"
        case .right: ">"
        }
    }
}

private let numericPad = """
    789
    456
    123
     0A
    """

private let directionalPad = """
     ^A
    <v>
    """

public let day21 = Solution(
    name: "day21",
    part1: part1,
    part2: part2
)
