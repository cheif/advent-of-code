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

func day6(_ input: String) -> (Int, Int) {
    let initialFish = input.trimmingCharacters(in: .newlines).split(separator: ",").map { Int($0)! }
    func simulateDay(current: [Int], day: Int) -> [Int] {
        let first = current.first ?? 0
        var next = current.dropFirst() + [first]
        next[7] += first
        return Array(next)
    }
    let grouped = (0...8).map { offset in
        initialFish.filter { $0 == offset }.count
    }
    let after80 = (1...80).lazy.reduce(grouped, simulateDay)
    let after256 = (1...256).reduce(grouped, simulateDay)
    return (after80.sum, after256.sum)
}

func day7(_ input: String) -> (Int, Int) {
    let start = input.trimmingCharacters(in: .newlines).split(separator: ",").map { Int($0)! }
    let possiblePositions = start.min()!...start.max()!
    let distances = possiblePositions.map { position in start.map { abs($0 - position) } }

    let cost2 = CachedFunc { (diff: Int) -> Int in Array((0...diff)).sum }
    return (distances.map(\.sum).min()!, distances.map { $0.map(cost2).sum }.min()!)
}

func day8(_ input: String) -> (Int, Int) {
    let lines: [(patterns: [String], values: [String])] = input.split(separator: "\n").map {
        let split = $0.components(separatedBy: " | ")
        return (split[0].components(separatedBy: " ").map { String($0.sorted()) }, split[1].components(separatedBy: " ").map { String($0.sorted()) })
    }

    let onesAndFoursAndSevensAndEights = lines.flatMap(\.values).filter { [2, 4, 3, 7].contains($0.count) }
    func value(of str: String, in patterns: [String]) -> Int {
        let zeroOrSixOrNine = patterns.filter { $0.count == 6 }
        assert(zeroOrSixOrNine.count == 3)
        let twoOrThreeOrFive = patterns.filter { $0.count == 5 }
        assert(twoOrThreeOrFive.count == 3)
        let one = patterns.first(where: { $0.count == 2 })!
        let four = patterns.first(where: { $0.count == 4 })!
        let nine = zeroOrSixOrNine.filter(one.hasAllCharacters).first(where: four.hasAllCharacters)!
        let twoOrFive = twoOrThreeOrFive.filter { !one.hasAllCharacters($0) }
        let mapping: [String: Int] = [
            zeroOrSixOrNine.filter(one.hasAllCharacters).first(where: { !four.hasAllCharacters($0) })!: 0,
            one: 1,
            twoOrFive.first(where: { !$0.hasAllCharacters(nine) })!: 2,
            twoOrThreeOrFive.first(where: one.hasAllCharacters)!: 3,
            four: 4,
            twoOrFive.first(where: { $0.hasAllCharacters(nine) })!: 5,
            zeroOrSixOrNine.first(where: { !one.hasAllCharacters($0) })!: 6,
            patterns.first(where: { $0.count == 3 })!: 7,
            patterns.first(where: { $0.count == 7 })!: 8,
            nine: 9
        ]
        return mapping[str]!
    }
    let values = lines
        .map { patterns, values -> Int in
            values.reversed().enumerated().map { exponent, string in
                value(of: string, in: patterns) * Int(powf(10, Float(exponent)))
            }.sum
        }
    return (onesAndFoursAndSevensAndEights.count, values.sum)
}

func day9(_ input: String) -> (Int, Int) {
    let matrix = Matrix(input)
    let lowPoints = matrix.points.filter { point in point.neighbours.allSatisfy { point.value < $0.value }}
    let allBasins = lowPoints.map { $0.connectedNeighbours(while: { $0.value < 9 }) }
    let sizedBasins = allBasins.map(\.count).sorted().reversed()
    return (lowPoints.map { $0.value + 1 }.sum, sizedBasins.prefix(3).reduce(1, *))
}

func day10(_ input: String) -> (Int, Int) {
    let lines = input.split(separator: "\n").map { $0.map { $0 as Character }}
    let pairMapping: [Character: Character] = [
        "(": ")",
        "[": "]",
        "{": "}",
        "<": ">"
    ]
    func firstCorrupted(in line: [Character]) -> Character? {
        var stack: [Character] = []
        for char in line {
            if ["(", "[", "{", "<"].contains(char) {
                stack.append(char)
            } else {
                // Must be closing
                guard let opening = stack.popLast() else {
                    return nil
                }
                guard pairMapping[opening] == char else {
                    return char
                }
            }
        }
        return nil
    }
    func corruptedPoint(for char: Character) -> Int {
        switch char {
        case ")": return 3
        case "]": return 57
        case "}": return 1197
        case ">": return 25137
        default: fatalError()
        }
    }
    let corruptedPoints = lines.compactMap(firstCorrupted).map(corruptedPoint)
    let nonCorruptedLines = lines.filter { firstCorrupted(in: $0) == nil }
    let completionsNeeded = nonCorruptedLines.map { line -> [Character] in
        let remaining: [Character] = line.reduce([]) { acc, char in
            if pairMapping[char] != nil {
                return acc + [char]
            } else {
                assert(pairMapping[acc.last!] == char)
                return acc.dropLast()
            }
        }
        return remaining.reversed().map { pairMapping[$0]! }
    }
    func completionPoint(for char: Character) -> Int {
        switch char {
        case ")": return 1
        case "]": return 2
        case "}": return 3
        case ">": return 4
        default: fatalError()
        }
    }
    let completionPoints = completionsNeeded.map { completions in
        completions.reduce(0) { total, completion in total * 5 + completionPoint(for: completion) }
    }

    return (corruptedPoints.sum, completionPoints.sorted()[(completionPoints.count - 1) / 2])
}

func day11(_ input: String) -> (Int, Int) {
    let initial: [[Int]] = input.split(separator: "\n").map { $0.map { Int(String($0))! }}
    func getFlashing(matrix: [[Int]]) -> Set<Point> {
        Set(matrix.enumerated().filter { $0.value > 9 }.map(\.point))
    }
    func simulateStep(_ matrix: [[Int]]) -> [[Int]] {
        var increased = matrix.map { $0.map { $0 + 1 }}
        var flashing = Set<Point>()
        while !getFlashing(matrix: increased).isSubset(of: flashing) {
            let new = getFlashing(matrix: increased).filter { !flashing.contains($0) }
            for point in new.flatMap(increased.neighbours) {
                increased[point] += 1
            }
            flashing.formUnion(new)
        }
        return increased.map { $0.map { $0 > 9 ? 0 : $0 }}
    }
    let steps = (1...100).reduce([initial]) { acc, step in acc + [simulateStep(acc.last!)] }
    let flashCount = steps.map { $0.flatMap { $0 }.filter { $0 == 0 }.count }
    var state = initial
    let allFlash = (1...).lazy.first(where: { step in
        state = simulateStep(state)
        return state.flatMap { $0 }.allSatisfy { $0 == 0 }
    })
    return (flashCount.sum, allFlash!)
}

func day12(_ input: String) -> (Int, Int) {
    typealias Connection = (start: String, end: String)
    typealias Path = [Connection]
    let connections: [Connection] = input.split(separator: "\n").map {
        let split = $0.components(separatedBy: "-")
        return (split[0], split[1])
    }
    let allConnections = connections + connections.map { ($0.end, $0.start) }

    func extensions(for path: Path, validityCheck: (Path) -> Bool) -> [Path] {
        let node = path.last!.end
        let outbound = allConnections.filter { $0.start == node && $0.end != "start" }
        return outbound
            .map { connection in path + [connection] }
            .filter(validityCheck)
            .flatMap { path in
                path.last?.end == "end" ? [path] : extensions(for: path, validityCheck: validityCheck)
            }
    }

    func nodes(path: Path) -> [String] { [path[0].start] + path.map(\.end) }
    func isValidFirst(path: Path) -> Bool {
        let lowerCaseNodes = nodes(path: path).filter(\.isLowerCase)
        return lowerCaseNodes.count == Set(lowerCaseNodes).count
    }

    func isValidSecond(path: Path) -> Bool {
        let nodes = nodes(path: path)
        let lowerCaseNodes = nodes.filter(\.isLowerCase)
        return lowerCaseNodes.count <= Set(lowerCaseNodes).count + 1
    }
    let starts = allConnections.filter { $0.start == "start" }.map { [$0] }
    let paths = starts.flatMap { path in extensions(for: path, validityCheck: isValidFirst(path:)) }
    let pathsSecond = starts.flatMap { path in extensions(for: path, validityCheck: isValidSecond(path:)) }
    return (paths.count, pathsSecond.count)
}

func day13(_ input: String) -> (Int, Int) {
    let split = input.components(separatedBy: "\n\n")
    typealias Paper = [Point]
    let paper: Paper = split[0].split(separator: "\n").map(Point.init)
    typealias Fold = (axis: Character, offset: Int)
    let folds = split[1].split(separator: "\n").map { string -> Fold in
        let split = string.split(separator: "=")
        return (axis: split[0].last!, offset: Int(split[1])!)
    }
    func process(paper: Paper, fold: Fold) -> Paper {
        let toInvert: Paper
        let inverted: Paper
        switch fold.axis {
        case "x":
            toInvert = paper.filter { $0.x > fold.offset }
            inverted = toInvert.map { Point(x: 2*fold.offset - $0.x, y: $0.y) }
        case "y":
            toInvert = paper.filter { $0.y > fold.offset }
            inverted = toInvert.map { Point(x: $0.x, y: 2*fold.offset - $0.y) }
        default:
            fatalError()
        }
        return Set(paper.filter { !toInvert.contains($0) } + inverted).sorted()
    }
    func print(_ paper: Paper) {
        let maxX = paper.max()!.x
        let maxY = paper.max(by: { $0.y < $1.y })!.y

        let allPoints = (0...maxY).map { y in (0...maxX).map { x in Point(x: x, y: y) }}
        let debug = allPoints.map { points in points.map { paper.contains($0) ? "#" : "." }.joined(separator: "")}
        for line in debug {
            Swift.print(line)
        }
    }
    let first = process(paper: paper, fold: folds[0])
    let finished = folds.reduce(paper, process(paper:fold:))
    print(finished)
    return (first.count, 0)
}

func day14(_ input: String) -> (Int, Int) {
    let splits = input.components(separatedBy: "\n\n")
    let startingTemplate = splits[0]
    let insertionRules: [String: Character] = Dictionary(splits[1].split(separator: "\n").map { string in
        let split = string.components(separatedBy: " -> ")
        return (split[0], Character(split[1]))
    }, uniquingKeysWith: { lhs, _ in lhs })

    let startingPairs = (0..<startingTemplate.count - 1).map { offset in String(startingTemplate.dropFirst(offset).prefix(2)) }.occurances()
    func newPairs(from pair: String) -> [String] {
        if let insertion = insertionRules[pair] {
            return [
                String(pair.first!) + String(insertion),
                String(insertion) + String(pair.last!)
            ]
        } else {
            return [pair]
        }
    }
    func step(pairs: [String: Int]) -> [String: Int] {
        let newPairs = pairs.map { pair, amount in (newPairs(from: pair), amount) }
        return newPairs.reduce([:]) { acc, pairs -> [String: Int] in
            let updated = Dictionary(pairs.0.map { ($0, pairs.1) }, uniquingKeysWith: { lhs, _ in lhs })
            return acc.merging(updated, uniquingKeysWith: { lhs, rhs in lhs + rhs })
        }
    }
    func getResult(pairs: [String: Int]) -> Int {
        // We only need to count the first value of each pair, and then add a count of one for the last ever character (that will never change)
        let characterCounts = pairs.map { pair, value in (pair.first!, value) } + [(startingTemplate.last!, 1)]
        let occurances = Dictionary(grouping: characterCounts, by: { $0.0 }).mapValues { $0.map(\.1).sum }.sorted(by: { lhs, rhs in lhs.value < rhs.value })
        return occurances.last!.value - occurances.first!.value
    }
    let afterTenSteps = (0..<10).reduce(startingPairs) { pairs, offset in step(pairs: pairs)}

    let afterFortySteps = (0..<40).reduce(startingPairs) { pairs, offset in step(pairs: pairs) }
    return (getResult(pairs: afterTenSteps), getResult(pairs: afterFortySteps))
}

func day15(_ input: String) -> (Int, Int) {
    typealias Path = [Point]
    func recontructPath(mapping: [Point: Point], current: Point) -> Path {
        var path = [current]
        var current = current
        while mapping[current] != nil {
            current = mapping[current]!
            path.append(current)
        }
        return path
    }
    func aStar(start: Point, goal: Point, estimatedCostToGoal: (Point) -> Int, getNeighbours: (Point) -> [(Point, Int)]) -> Path {
        var openSet: Set<Point> = .init([start])
        var cameFrom: [Point: Point] = [:]
        var gScore: [Point: Int] = [start: 0]
        var fScore: [Point: Int] = [start: estimatedCostToGoal(start)]

        while !openSet.isEmpty {
            let current = openSet.min(by: { fScore[$0, default: .max] < fScore[$1, default: .max] })!
            if current == goal {
                return recontructPath(mapping: cameFrom, current: current)
            }
            openSet.remove(current)
            for (neighbour, cost) in getNeighbours(current) {
                let tentativeGScore = gScore[current, default: .max] + cost
                if tentativeGScore < gScore[neighbour, default: .max] {
                    cameFrom[neighbour] = current
                    gScore[neighbour] = tentativeGScore
                    fScore[neighbour] = tentativeGScore + estimatedCostToGoal(neighbour)
                    openSet.insert(neighbour)
                }
            }
        }
        return []
    }

    let startMatrix = input.split(separator: "\n").map { $0.map { Int(String($0))! }}
    let start = Point(x: 0, y: 0)

    func getNeighbours(for point: Point, endPoint: Point, pointCost: (Point) -> Int) -> [(Point, Int)] {
        let neighbours = [
            Point(x: point.x - 1, y: point.y),
            Point(x: point.x + 1, y: point.y),
            Point(x: point.x, y: point.y - 1),
            Point(x: point.x, y: point.y + 1)
        ].filter { $0.x >= 0 && $0.y >= 0 && $0.x <= endPoint.x && $0.y <= endPoint.y }
        return neighbours.map { ($0, pointCost($0)) }
    }

    func pointCost(point: Point) -> Int {
        if startMatrix.contains(point) {
            return startMatrix[point]
        } else {
            var increase = 0
            var x = point.x
            var y = point.y
            if point.x >= startMatrix.count {
                increase += Int(floor(Float(point.x) / Float(startMatrix.count)))
                x = point.x % startMatrix.count
            }
            if point.y >= startMatrix[0].count {
                increase += Int(floor(Float(point.y) / Float(startMatrix[0].count)))
                y = point.y % startMatrix[0].count
            }
            let originalPoint = Point(x: x, y: y)
            return ((startMatrix[originalPoint] + increase - 1) % 9) + 1
        }
    }
    func pathCost(for path: Path) -> Int { path.filter { $0 != start }.map(pointCost).sum }

    let end = Point(x: startMatrix.count - 1, y: startMatrix[0].count - 1)
    let path = aStar(start: start, goal: end, estimatedCostToGoal: { end.x - $0.x + end.y - $0.y }, getNeighbours: { point in getNeighbours(for: point, endPoint: end, pointCost: pointCost) })

    let end2 = Point(x: startMatrix.count * 5 - 1, y: startMatrix[0].count * 5 - 1)
    let path2 = aStar(start: start, goal: end2, estimatedCostToGoal: { end2.x - $0.x + end2.y - $0.y }, getNeighbours: { point in getNeighbours(for: point, endPoint: end2, pointCost: pointCost) })

    return (pathCost(for: path), pathCost(for: path2))
}

extension String {
    var isLowerCase: Bool {
        allSatisfy(\.isLowercase)
    }
}

extension Array where Element: MutableCollection {
    func enumerated() -> [(point: Point, value: Element.Element)] {
        enumerated().flatMap { y, row in
            row.enumerated().map { x, value in (point: Point(x: x, y: y), value: value) }
        }
    }

    func neighbours(to point: Point) -> [Point] {
        let candidates = (-1...1).flatMap { y in
            (-1...1).map { x in
                Point(x: point.x + x, y: point.y + y)
            }
        }
        return candidates.filter(contains).filter { $0 != point }
    }

    func contains(_ point: Point) -> Bool {
        indices.contains(point.y) && first!.indices.contains(point.x as! Element.Index)
    }

    subscript(index: Point) -> Element.Element {
        get {
            self[index.y][index.x as! Element.Index]
        }
        set(newValue) {
            self[index.y][index.x as! Element.Index] = newValue
        }
    }
}

struct Matrix {
    let points: [Point]
    init(_ input: String) {
        let rows = input.split(separator: "\n").map { $0.map { Int(String($0))! }}
        let coordinates = (0..<rows.count).flatMap { y in
            (0..<rows[0].count).map { x in (x, y) } }
        points = coordinates.map { Point(matrix: rows, coordinate: $0) }
    }

    struct Point: Hashable, CustomStringConvertible {
        private let matrix: [[Int]]
        let x: Int
        let y: Int

        var value: Int {
            matrix[y][x]
        }

        var description: String {
            "Point(\(x), \(y), value=\(value))"
        }

        init(matrix: [[Int]], coordinate: (x: Int, y: Int)) {
            self.matrix = matrix
            self.x = coordinate.x
            self.y = coordinate.y
        }

        var neighbours: [Point] {
            let coordinates = [
                (x-1, y),
                (x+1, y),
                (x, y-1),
                (x, y+1)
            ].filter { x,y in
                matrix.indices.contains(y) && matrix[y].indices.contains(x)
            }

            return coordinates.map { Point(matrix: matrix, coordinate: $0) }
        }

        func connectedNeighbours(while predicate: (Point) -> Bool) -> Set<Point> {
            var points = Set([self])
            var candidates = Set(neighbours)
            while let point = candidates.popFirst() {
                if predicate(point) {
                    points.insert(point)
                    candidates.formUnion(point.neighbours.filter { !points.contains($0) })
                }
            }
            return points
        }
    }
}

extension String {
    func hasAllCharacters(_ other: String) -> Bool {
        allSatisfy(other.contains)
    }
}

struct Point: Hashable, Comparable, CustomStringConvertible {
    let x: Int
    let y: Int

    var description: String { "Point(\(x), \(y))" }
    static func < (lhs: Point, rhs: Point) -> Bool {
        lhs.x < rhs.x ? true :
            lhs.x == rhs.x ? lhs.y < rhs.y : false
    }
}

extension Point {
    init<S: StringProtocol>(_ str: S) {
        let split = str.split(separator: ",")
        self.init(x: Int(split[0])!, y: Int(split[1])!)
    }
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

private extension Collection where Element: Numeric {
    var sum: Element {
        reduce(.zero, +)
    }
}

private extension Array where Element: Numeric, Element: Comparable {
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

    func get(_ offset: Index) -> Element? {
        indices.contains(offset) ? self[offset] : nil
    }
}

func CachedFunc<Key: Hashable, Value>(block: @escaping (Key) -> Value) -> ((Key) -> Value) {
    var cache = Dictionary<Key, Value>()

    return { key in
        if let cached = cache[key] {
            return cached
        } else {
            let res = block(key)
            cache[key] = res
            return res
        }
    }
}
