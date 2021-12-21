import Algorithms
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

func day16(_ input: String) -> (Int, Int) {
    let chunks: [String] = input.trimmingCharacters(in: .newlines).map { String(Int(String($0), radix: 16)!, radix: 2) }.map { String(("0000" + $0).suffix(4)) }
    let binary: [Character] = chunks.flatMap { $0.map { $0 }}

    struct Packet {
        let version: Int
        let type: PkgType

        enum PkgType {
            case literal(Int)
            case op(Op, [Packet])
        }

        enum Op: Int {
            case sum
            case product
            case minimum
            case maximum
            case greaterThan = 5
            case lessThan = 6
            case equalTo = 7
        }
    }
    func parsePacket(input: [Character]) -> (Packet, [Character]) {
        let version = Int(String(input.prefix(3)), radix: 2)!
        let type = Int(String(input.dropFirst(3).prefix(3)), radix: 2)!
        let body = Array(input.dropFirst(6))
        let isOperator = type != 4
        if isOperator {
            let op = Packet.Op(rawValue: type)!
            let lengthTypeId = Int(String(body.first!), radix: 2)!
            let remainder = body.dropFirst()

            switch lengthTypeId {
            case 0:
                let subPacketLength = Int(String(remainder.prefix(15)), radix: 2)!
                var subPacketData = Array(remainder.dropFirst(15).prefix(subPacketLength))
                var subPackets: [Packet] = []
                while !subPacketData.isEmpty {
                    let (packet, remainder) = parsePacket(input: subPacketData)
                    subPackets.append(packet)
                    subPacketData = remainder
                }
                return (.init(version: version, type: .op(op, subPackets)), Array(remainder.dropFirst(15 + subPacketLength)))
            case 1:
                let subPacketCount = Int(String(remainder.prefix(11)), radix: 2)!
                let (subPackets, remainder) = (0..<subPacketCount).reduce(([], Array(remainder.dropFirst(11)))) { acc, _ -> ([Packet], [Character])in
                    let (packet, remainder) = parsePacket(input: acc.1)
                    return (acc.0 + [packet], remainder)
                }
                return (.init(version: version, type: .op(op, subPackets)), remainder)
            default:
                fatalError()
            }
        } else {
            let numberOfGroups = body.chunked(into: 5).prefix(while: { $0[0] == "1" }).count + 1
            let value = body.chunked(into: 5).prefix(numberOfGroups).map { $0.dropFirst() }.map { String($0) }.joined()
            return (.init(version: version, type: .literal(Int(value, radix: 2)!)), Array(body.dropFirst(numberOfGroups * 5)))
        }
    }

    func totalVersion(for packet: Packet) -> Int {
        switch packet.type {
        case .literal:
            return packet.version
        case .op(_, let subPackets):
            return packet.version + subPackets.map(totalVersion).sum
        }
    }
    func computeValue(for packet: Packet) -> Int {
        switch packet.type {
        case .literal(let value):
            return value
        case .op(let op, let subPackets):
            let subValues = subPackets.map(computeValue)
            switch op {
            case .sum:
                return subValues.sum
            case .product:
                return subValues.reduce(1, *)
            case .minimum:
                return subValues.min()!
            case .maximum:
                return subValues.max()!
            case .greaterThan:
                assert(subValues.count == 2)
                return subValues[0] > subValues[1] ? 1 : 0
            case .lessThan:
                assert(subValues.count == 2)
                return subValues[0] < subValues[1] ? 1 : 0
            case .equalTo:
                assert(subValues.count == 2)
                return subValues[0] == subValues[1] ? 1 : 0
            }
        }
    }
    let packet = parsePacket(input: binary).0
    return (totalVersion(for: packet), computeValue(for: packet))
}

func day17(_ input: String) -> (Int, Int) {
    let start = Point(x: 0, y: 0)
    let split = input.trimmingCharacters(in: .newlines).split(separator: "=", maxSplits: 1)[1].components(separatedBy: ", y=").flatMap { $0.components(separatedBy: "..").map { Int($0)! }}
    let targetArea = (split[0]...split[1], split[2]...split[3])

    typealias State = (position: Point, velocity: Point)
    func step(state: State) -> State {
        (
            position: Point(x: state.position.x + state.velocity.x, y: state.position.y + state.velocity.y),
            velocity: .init(x: max(0, state.velocity.x - 1), y: state.velocity.y - 1)
        )
    }
    func simulate(state: State, targetArea: (xRange: ClosedRange<Int>, yRange: ClosedRange<Int>)) -> [State]? {
        if targetArea.xRange.contains(state.position.x) && targetArea.yRange.contains(state.position.y) {
            // We're in the target-area
            return [state]
        } else if state.position.x > targetArea.xRange.max()! || state.position.y < targetArea.yRange.min()! {
            // We're past the target, exit
            return nil
        } else if state.velocity.x <= 0 && !targetArea.xRange.contains(state.position.x) {
            // We're not moving horizontally any more, exit
            return nil
        } else {
            // need another iteration
            return simulate(state: step(state: state), targetArea: targetArea).map { [state] + $0 }
        }
    }
    func maxY(initial: State, targetArea: (xRange: ClosedRange<Int>, yRange: ClosedRange<Int>)) -> Int? {
        simulate(state: initial, targetArea: targetArea).map { $0.map(\.position.y).max()! }
    }

    let xCandidates = 0...targetArea.0.max()!
    let yCandidates = targetArea.1.min()!...300
    let states: [State] = xCandidates.flatMap { xVel in yCandidates.map { yVel in (start, Point(x: xVel, y: yVel)) }}
    let validStates = states.compactMap { state in simulate(state: state, targetArea: targetArea) }
    let highestYPosition = validStates.map { steps in steps.map(\.position.y).max()! }.max()!
    return (highestYPosition, validStates.count)
}

func day18(_ input: String) -> (Int, Int) {
    indirect enum Number: CustomStringConvertible, Equatable {
        case regular(Int)
        case pair(Number, Number)

        var description: String {
            switch self {
            case .regular(let number):
                return "\(number)"
            case .pair(let lhs, let rhs):
                return "[\(lhs),\(rhs)]"
            }
        }

        init<S: StringProtocol>(_ string: S) {
            if let regular = Int(String(string)) {
                self = .regular(regular)
            } else {
                var bracketCount = 0
                var lhs = ""
                for char in string.dropFirst() {
                    lhs.append(char)
                    switch char {
                    case "[":
                        bracketCount += 1
                    case "]":
                        bracketCount -= 1
                    default:
                        break
                    }
                    if bracketCount == 0 {
                        break
                    }
                }
                let rhs = string.dropFirst(1 + lhs.count + 1).dropLast()
                self = .pair(.init(lhs), .init(rhs))
            }
        }

        func add(_ other: Self) -> Self {
            .pair(self, other)
        }

        func addToLeftMost(number: Int?) -> Self {
            switch self {
            case .pair(let lhs, let rhs):
                return .pair(lhs.addToLeftMost(number: number), rhs)
            case .regular(let value):
                return .regular(value + (number ?? 0))
            }
        }

        func addToRightMost(number: Int?) -> Self {
            switch self {
            case .pair(let lhs, let rhs):
                return .pair(lhs, rhs.addToRightMost(number: number))
            case .regular(let value):
                return .regular(value + (number ?? 0))
            }
        }

        func _explode(depth: Int) -> (Int?, Self, Int?) {
            switch self {
            case .pair(.regular(let lhs), .regular(let rhs)):
                if depth >= 4 {
                    // This is the pair to explode!
                    return (lhs, .regular(0), rhs)
                }
                return (nil, self, nil)
            case .pair(let lhs, let rhs):
                guard depth < 4 else {
                    fatalError("Incorrect state!")
                }
                let left = lhs._explode(depth: depth + 1)
                if left.1 != lhs {
                    // Left was exploded, now we need to add it's number to right, and return left
                    return (left.0, .pair(left.1, rhs.addToLeftMost(number: left.2)), nil)
                }
                let right = rhs._explode(depth: depth + 1)
                if right.1 != rhs {
                    // Right was exploded, now we need to add it's number to left, and return right
                    return (nil, .pair(lhs.addToRightMost(number: right.0), right.1), right.2)
                }
                return (nil, .pair(left.1, right.1), nil)
            case .regular:
                return (nil, self, nil)
            }
        }

        func explode(depth: Int = 0) -> Self {
            _explode(depth: depth).1
        }

        func split() -> Self {
            switch self {
            case .pair(let lhs, let rhs):
                let leftSplit = lhs.split()
                if leftSplit != lhs {
                    return .pair(leftSplit, rhs)
                } else {
                    return .pair(lhs, rhs.split())
                }
            case .regular(let number) where number >= 10:
                return .pair(.regular(Int(floor(Float(number)/2))), .regular(Int(ceil(Float(number)/2))))
            case .regular:
                return self
            }
        }

        func reduce() -> Self {
            let exploded = explode()
            if exploded != self {
                return exploded.reduce()
            }
            let splitted = split()
            if splitted != self {
                return splitted.reduce()
            }
            return self
        }

        func magnitude() -> Int {
            switch self {
            case .pair(let lhs, let rhs):
                return lhs.magnitude() * 3 + rhs.magnitude() * 2
            case .regular(let number):
                return number
            }

        }
    }
    let start: [Number] = input.split(separator: "\n").map(Number.init)
    let result = start.dropFirst().reduce(start[0]) { acc, num in acc.add(num).reduce() }
    let combinations = start.combinations(ofCount: 2)
    let maxSum = combinations.map { numbers -> Int in
        let lhs = numbers[0]
        let rhs = numbers[1]
        return max(lhs.add(rhs).reduce().magnitude(), rhs.add(lhs).reduce().magnitude())
    }.max()!
    return(result.magnitude(), maxSum)
}

func day19(_ input: String) -> (Int, Int) {
    struct Scanner: Equatable {
        let id: Int
        typealias Probe = ThreeDPoint
        let probes: [Probe]

        init(_ string: String) {
            let lines = string.components(separatedBy: "\n")
            id = Int(lines[0].split(separator: " ")[2])!
            probes = lines.dropFirst().map(Probe.init)
        }

        init(id: Int, probes: [Probe]) {
            self.id = id
            self.probes = probes
        }

        func overlapping(scanner other: Self, rotations: [(ThreeDPoint) -> ThreeDPoint]) -> (ThreeDPoint, (ThreeDPoint) -> ThreeDPoint)? {
            for rotation in rotations {
                let rotated = other.rotate(rotation)
                let pairs = product(probes, rotated.probes)
                let translations = pairs.map { $0 - $1 }
                let best = translations.occurances().max(by: { lhs, rhs in lhs.value < rhs.value })!
                if best.value >= 12 {
                    // We found at least 12 overlapping probes, return all probes using this translation
                    return (best.key, rotation)
                }
            }
            return nil
        }

        func rotate(_ mapping: (ThreeDPoint) -> ThreeDPoint) -> Self {
            .init(
                id: id,
                probes: probes.map(mapping)
            )
        }
    }

    // All mappings where we have (+/-)(x/y/z) as forward
    let forwardMappings: [(ThreeDPoint) -> ThreeDPoint] = [
        { .init(x: $0.x, y: $0.y, z: $0.z) },
        { .init(x: -$0.y, y: $0.x, z: $0.z) },
        { .init(x: -$0.x, y: -$0.y, z: $0.z) },
        { .init(x: $0.y, y: -$0.x, z: $0.z) },
        { .init(x: $0.z, y: $0.y, z: -$0.x) },
        { .init(x: -$0.z, y: $0.y, z: $0.x) }
    ]

    // Now we just need to rotate all of the above around the x-axis four times to get all 24 possible rotations
    func rotateAroundX(_ point: ThreeDPoint, numberOfQuarters: Int) -> ThreeDPoint {
        switch numberOfQuarters {
        case 0:
            return point
        case 1:
            return .init(x: point.x, y: point.z, z: -point.y)
        case 2:
            return .init(x: point.x, y: -point.y, z: -point.z)
        case 3:
            return .init(x: point.x, y: -point.z, z: point.y)
        default:
            fatalError()
        }
    }
    let allRotations: [(ThreeDPoint) -> ThreeDPoint] = forwardMappings.flatMap { mapping in (0...3).map { quarters in { rotateAroundX(mapping($0), numberOfQuarters: quarters) }}}

    let scanners = input.trimmingCharacters(in: .newlines).components(separatedBy: "\n\n").map(Scanner.init)
    var candidates = Array(scanners.dropFirst())
    typealias TranslatedScanner = (scanner: Scanner, translation: ThreeDPoint, rotation: (ThreeDPoint) -> ThreeDPoint)
    var completed: [TranslatedScanner] = [(scanner: scanners[0], translation: ThreeDPoint(x: 0, y: 0, z: 0), rotation: { $0 })]
    var toCheck: [TranslatedScanner] = completed
    while !toCheck.isEmpty {
        let checking = toCheck.popLast()!
        let matches: [TranslatedScanner] = candidates.compactMap { scanner in
            let inner: TranslatedScanner? = checking.scanner.overlapping(scanner: scanner, rotations: allRotations).map { translation, rotation in (scanner, translation, rotation) }
            return inner.map { scanner, translation, rotation in (scanner, checking.rotation(translation) + checking.translation, { checking.rotation(rotation($0)) })}
        }
        completed.append(contentsOf: matches)
        toCheck.append(contentsOf: matches)
        candidates.removeAll(where: { matches.map(\.scanner.id).contains($0.id) })
        print("Found: \(matches.count)")
        print("To check: \(candidates.count)")
    }
    let allProbes = completed.flatMap { scanner, translation, rotation in scanner.probes.map(rotation).map { $0 + translation }}
    print(completed.map(\.translation))
    print(completed.combinations(ofCount: 2).count)
    let maxDistance = completed.map(\.translation).combinations(ofCount: 2).map { points in points[0].distance(to: points[1]) }.max()!
    return (Array(allProbes.uniqued()).count, maxDistance)
}

func day20(_ input: String) -> (Int, Int) {
    let lines = input.trimmingCharacters(in: .newlines).components(separatedBy: "\n\n")
    assert(lines.count == 2)
    let algo = lines[0]
    assert(algo.count == 512)
    typealias Image = [[Character]]
    let inputImage: Image = lines[1].components(separatedBy: "\n").map { $0.map { $0 }}

    func neighbours(to point: Point, in image: Image, iteration: Int) -> [Character] {
        let candidates = (-1...1).flatMap { y in
            (-1...1).map { x in
                Point(x: point.x + x, y: point.y + y)
            }
        }
        let zeroFill = algo.first!
        let fillValue = !iteration.isMultiple(of: 2) ? zeroFill : (zeroFill == "#" ? algo.last! : zeroFill)
        return candidates.map { image.contains($0) ? image[$0] : fillValue }
    }

    func enhance(characters: [Character]) -> Character {
        let value = Int(characters.map { $0 == "#" ? "1" : "0"}.joined(), radix: 2)!
        let index = algo.index(algo.startIndex, offsetBy: value)
        return algo[index]
    }

    func enhance(image: Image, iteration: Int) -> Image {
        let expansion = 1
        let coordinates = (-expansion..<image.count+expansion).map { y in (-expansion..<image[0].count+expansion).map { x in Point(x: x, y: y) }}
        let new = coordinates.map { points in
            points.map { neighbours(to: $0, in: image, iteration: iteration) }
                .map { enhance(characters: $0) }
        }
        return new
    }
    func printImage(_ image: Image) {
        print(image.map { $0.map { String($0) }.joined() }.joined(separator: "\n"))
    }
    func litCount(_ image: Image) -> Int { image.map { $0.filter { $0 == "#" }.count }.sum }
    let doubleEnhanced = enhance(image: enhance(image: inputImage, iteration: 0), iteration: 1)
    print(inputImage.count)
    let fiftyTimesEnhanced = (0..<50).reduce(inputImage, enhance(image:iteration:))
    print(fiftyTimesEnhanced.count)

    return (litCount(doubleEnhanced), litCount(fiftyTimesEnhanced))
}

func day21(_ input: String) -> (Int, Int) {
    struct Player: Hashable {
        var position: Int
        var score: Int = 0

        init(_ string: String) {
            position = Int(string.components(separatedBy: ": ")[1])!
        }

        init(position: Int, score: Int) {
            self.position = position
            self.score = score
        }

        mutating func moved(_ steps: Int) {
            position = ((position + steps - 1) % 10) + 1
            score += position
        }

        func move(_ steps: Int) -> Self {
            let newPosition = ((position + steps - 1) % 10) + 1
            return .init(
                position: newPosition,
                score: score + newPosition
            )
        }
    }

    struct DeterministicDie {
        var state = 0
        var rolls = 0
        mutating func roll() -> Int {
            let roll = state + 1
            state = (state + 1 % 100)
            rolls += 1
            return roll
        }

        mutating func roll3x() -> Int {
            (0..<3).map { _ in roll() }.sum
        }
    }

    struct DiracDie {
        func roll() -> [Int] {
            return [1, 2, 3]
        }

        func roll3x() -> [[Int]] {
            Array(product(roll(), product(roll(), roll())).map { [$0, $1.0, $1.1] })
        }

        lazy var combinations: [Int: Int] = roll3x().map(\.sum).occurances()

        // Play, and return the number of universes the users win in
        mutating func play(_ players: [Player]) -> (Int, Int) {
            let initialState = State(player1: players[0], player2: players[1], player1ToPlay: true)
            var statesToCheck: Set<State> = .init(arrayLiteral: initialState)
            let target = 21
            var cache: [State: (Int, Int)] = [:]
            while cache[initialState] == nil {
                if cache.count.isMultiple(of: 100) || statesToCheck.count.isMultiple(of: 100) {
                    print("cache: \(cache.count)")
                    print("toCheck: \(statesToCheck.count)")
                }
                let state = statesToCheck.popFirst() ?? initialState
                if cache[state] != nil {
                    continue
                } else if let score = state.score(for: target) {
                    cache[state] = score
                } else {
                    let subStates = expandState(state: state)
                    let unknownStates = subStates.map(\.state).filter { cache[$0] == nil }
                    if !unknownStates.isEmpty {
                        statesToCheck.formUnion(unknownStates)
                    } else {
                        // All substates known, now we can calculate the value for this state by adding them up together
                        let knownStates = subStates.compactMap { state, occurances in cache[state].map { ($0 * occurances, $1 * occurances) }}
                        cache[state] = knownStates.reduce((0, 0)) { acc, state in (acc.0 + state.0, acc.1 + state.1) }
                    }
                }
            }
            return cache[initialState]!
        }

        struct State: Hashable {
            let player1: Player
            let player2: Player
            let player1ToPlay: Bool

            func score(for target: Int) -> (Int, Int)? {
                if player1.score >= target {
                    return (1, 0)
                } else if player2.score >= target {
                    return (0, 1)
                } else {
                    return nil
                }
            }
        }

        private var expansionCache: [State: [(State, Int)]] = [:]
        mutating func expandState(state: State) -> [(state: State, occurances: Int)] {
            if let result = expansionCache[state] {
                return result
            }
            let result = combinations.map { steps, occurances -> (State, Int) in
                let newState = state.player1ToPlay ?
                State(
                    player1: state.player1.move(steps),
                    player2: state.player2,
                    player1ToPlay: false
                ) :
                State(
                    player1: state.player1,
                    player2: state.player2.move(steps),
                    player1ToPlay: true
                )
                return (newState, occurances)
            }
            expansionCache[state] = result
            return result
        }
    }

    let players = input.trimmingCharacters(in: .newlines).components(separatedBy: "\n").map(Player.init)
    var player1 = players[0]
    var player2 = players[1]
    var die = DeterministicDie()

    while player1.score < 1000 && player2.score < 1000 {
        player1.moved(die.roll3x())
        if player1.score >= 1000 {
            break
        }
        player2.moved(die.roll3x())
    }
    let losingScore = min(player1.score, player2.score)

    var diracDie = DiracDie()
    let diracScores = diracDie.play(players)

    return (losingScore * die.rolls, max(diracScores.0, diracScores.1))
}

extension RandomAccessCollection {
    func lazyCompactFirstMap<T>(_ transform: (Element) -> T?) -> T? {
        for element in self {
            if let result = transform(element) {
                return result
            }
        }
        return nil
    }
}

struct ThreeDPoint: Hashable, CustomStringConvertible {
    let x: Int
    let y: Int
    let z: Int

    init(_ string: String) {
        let split = string.split(separator: ",").map { Int($0)! }
        self.init(x: split[0], y: split[1], z: split[2])
    }

    init(x: Int, y: Int, z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }

    static func + (lhs: Self, rhs: Self) -> Self {
        .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }

    static func - (lhs: Self, rhs: Self) -> Self {
        .init(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    }

    func distance(to other: Self) -> Int {
        abs(other.x - x) + abs(other.y - y) + abs(other.z - z)
    }

    var description: String { "(\(x),\(y),\(z))" }
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
