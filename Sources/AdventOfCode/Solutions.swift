import Foundation

func day1(_ input: String) -> (Int, Int) {
    let depths: [Int] = input.decodeLines()
    return (depths.increases(), depths.windowed(size: 3).map(\.sum).increases())
}

func day2(_ input: String) -> (Int, Int) {
    enum Dir: String, StringDecodable {
        init?<S>(_ s: S) where S : StringProtocol {
            self.init(rawValue: String(s))
        }

        case up
        case down
        case forward
    }
    let directions: [(direction: Dir, amount: Int)] = input.decodeLines()
    let depth = directions.reduce(0) { acc, dir in
        switch dir.direction {
        case .up:
            return acc - dir.amount
        case .down:
            return acc + dir.amount
        case .forward:
            return acc
        }
    }
    let horizontal = directions.filter { $0.direction == .forward }.map(\.amount).sum
    let correctDepth = directions.reduce((depth: 0, aim: 0)) { acc, dir -> (depth: Int, aim: Int) in
        switch dir.direction {
        case .up:
            return (depth: acc.depth, aim: acc.aim - dir.amount)
        case .down:
            return (depth: acc.depth, aim: acc.aim + dir.amount)
        case .forward:
            return (depth: acc.depth + acc.aim * dir.amount, aim: acc.aim)
        }
    }.depth
    return (depth * horizontal, correctDepth * horizontal)
}

func day3(_ input: String) -> (Int, Int) {
    let bits: [[Character]] = input.split(separator: "\n").map(Array.init)
    let gammaRate = (0..<bits[0].count).map { offset in
        try! bits.map { $0[offset] }.mostCommon()!
    }
    let gamma = Int(String(gammaRate), radix: 2)!
    let epsilonRate = gammaRate.map(\.bitInverse)
    let epsilon = Int(String(epsilonRate), radix: 2)!

    let oxygenRate = (0..<bits[0].count).reduce(bits) { acc, offset -> [[Character]] in
        if acc.count == 1 {
            // finished
            return acc
        } else {
            let mostCommon = (try? acc.map { $0[offset] }.mostCommon()!) ?? "1"
            return acc.filter { $0[offset] == mostCommon }
        }
    }.first!
    let scrubberRate = (0..<bits[0].count).reduce(bits) { acc, offset -> [[Character]] in
        if acc.count == 1 {
            // finished
            return acc
        } else {
            let leastCommon = (try? acc.map { $0[offset] }.mostCommon()!.bitInverse) ?? "0"
            return acc.filter { $0[offset] == leastCommon }
        }
    }.first!
    let oxygen = Int(String(oxygenRate), radix: 2)!
    let scrubber = Int(String(scrubberRate), radix: 2)!
    return (gamma * epsilon, oxygen * scrubber)
}

func day4(_ input: String) -> (Int, Int) {
    let split = input.split(separator: "\n").map(String.init)
    let draws = split[0].split(separator: ",").map { Int($0)! }
    struct Board: Equatable, CustomStringConvertible {
        let lines: [[Int]]
        private var verticalLines: [[Int]] { (0..<5).map { offset in lines.map { $0[offset] }} }

        init(lines: [String]) {
            self.lines = lines.map { $0.split(separator: " ").map { Int($0)! }}
        }

        func winner(_ drawn: [Int]) -> Bool {
            func hasBingo(_ lines: [[Int]]) -> Bool {
                return lines.filter { $0.allSatisfy(drawn.contains) }.count > 0
            }
            return hasBingo(lines) || hasBingo(verticalLines)
        }

        func score(_ drawn: [Int]) -> Int {
            lines.flatMap { $0 }.filter { !drawn.contains($0) }.sum * drawn.last!
        }

        var description: String {
            lines.map { $0.map(String.init).joined(separator: " ") }.joined(separator: "\n")
        }
    }
    let boards = Array(split.suffix(from: 1)).chunked(into: 5).map(Board.init)

    var drawn: [Int] = []
    var winners: [(board: Board, drawn: [Int])] = []
    for current in draws {
        drawn.append(current)
        let contenders = boards.filter { !winners.map(\.board).contains($0) }
        winners.append(contentsOf: contenders.filter { $0.winner(drawn) }.map { ($0, drawn) })
        if winners.count == boards.count {
            break
        }
    }
    let scores = winners.map { $0.board.score($0.drawn) }
    return (scores[0], scores.last!)
}

func day5(_ input: String) -> (Int, Int) {
    let lines = input.split(separator: "\n").map(Line.init(arrowSeparated:))
    let horizontalVerticalOverlaps = lines
        .flatMap { $0.covers(includeDiagonal: false) }
        .occurances()
        .filter { _, count in count > 1 }.count
    let diagonalOverlaps = lines
        .flatMap { $0.covers(includeDiagonal: true) }
        .occurances()
        .filter { _, count in count > 1 }.count
    return (horizontalVerticalOverlaps, diagonalOverlaps)
}

struct Point: Hashable, CustomStringConvertible {
    let x: Int
    let y: Int

    var description: String { "Point(\(x), \(y))" }
}

struct Line: Hashable {
    let p1: Point
    let p2: Point

    init<S: StringProtocol>(arrowSeparated string: S) {
        let points = string.components(separatedBy: " -> ")
            .map { string -> Point in
                let splits = string.split(separator: ",")
                return .init(x: Int(splits[0])!, y: Int(splits[1])!)
            }
        p1 = points[0]
        p2 = points[1]
    }

    func covers(includeDiagonal: Bool) -> [Point] {
        let xs = stride(from: p1.x, to: p2.x, by: p1.x < p2.x ? 1 : -1) + [p2.x]
        let ys = stride(from: p1.y, to: p2.y, by: p1.y < p2.y ? 1 : -1) + [p2.y]
        if p1.y == p2.y {
            return xs.map { Point(x: $0, y: p1.y) }
        } else if p1.x == p2.x {
            return ys.map { Point(x: p1.x, y: $0) }
        } else if includeDiagonal {
            return zip(xs, ys).map { Point(x: $0, y: $1) }
        } else {
            return []
        }
    }
}

extension Character {
    var bitInverse: Character { self == "1" ? "0" : "1" }
}

extension Array where Element: Hashable {
    func mostCommon() throws -> Element? {
        try occurances().max(by: { lhs, rhs in
            if lhs.value  == rhs.value {
                throw Error.equal
            } else {
                return lhs.value < rhs.value
            }
        })?.key
    }

    func occurances() -> [Element: Int] {
        reduce([:]) { acc, curr -> [Element: Int] in
            let count = acc[curr] ?? 0
            return acc.merging([curr: count + 1], uniquingKeysWith: Swift.max)
        }
    }

    enum Error: Swift.Error {
        case equal
    }
}

protocol StringDecodable {
    init?<S: StringProtocol>(_ s: S)
}

extension Int: StringDecodable {
    init?<S>(_ s: S) where S : StringProtocol {
        self.init(s, radix: 10)
    }
}

private extension String {
    func decodeLines<T>() -> [T] where T: StringDecodable {
        split(separator: "\n")
            .map { T($0)! }
    }

    func decodeLines<T, V>() -> [(T, V)] where T: StringDecodable, V: StringDecodable {
        split(separator: "\n")
            .map { str -> (T, V) in
                let split = str.split(separator: " ")
                return (T(split[0])!, V(split[1])!)
            }
    }
}

private extension Array where Element: Numeric, Element: Comparable {
    var sum: Element {
        reduce(.zero, +)
    }

    func windowed(size: Int) -> [[Element]] {
        reduce([[]]) { acc, curr -> [[Element]] in
            let last = acc.last ?? []
            if last.count == size {
                let next = Array(last.suffix(size - 1) + [curr])
                return acc + [next]
            } else {
                let next = last + [curr]
                return [next]
            }
        }
    }

    func increases() -> Element {
        let reduced = reduce((0, nil)) { acc, curr -> (Element, Element?) in
            let (total, prev) = acc
            if let prev = prev,
               prev < curr {
                return (total + 1, curr)
            } else {
                return (total, curr)
            }
        }
        return reduced.0
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
