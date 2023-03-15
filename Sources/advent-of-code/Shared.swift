import Foundation

func zip3<A, B, C>(_ a: some Sequence<A>, _ b: some Sequence<B>, _ c: some Sequence<C>) -> some Sequence<(A, B, C)> {
    zip(zip(a, b), c).map { aAndB, c in (aAndB.0, aAndB.1, c) }
}

extension Collection where Element: Numeric {
    var sum: Element {
        reduce(0, +)
    }
}

extension Collection {
    func chunked(into size: Int) -> [[Element]] {
        var result: [[Element]] = []
        for element in self {
            if let lastSize = result.last?.count,
               lastSize < size {
                result[result.count - 1].append(element)
            } else {
                result.append([element])
            }
        }
        return result
    }
}

extension ClosedRange {
    func fullyContains(_ other: ClosedRange) -> Bool {
        lowerBound <= other.lowerBound && upperBound >= other.upperBound
    }

    func expanded(by size: Bound) -> Self where Bound: Numeric {
        Self(uncheckedBounds: (lowerBound - size, upperBound + size))
    }

    func shrinked(by size: Bound) -> Self where Bound: Numeric {
        Self(uncheckedBounds: (lowerBound + size, upperBound - size))
    }
}

struct Grid<V>: Hashable where V: Equatable, V: Hashable {
    let data: Set<Point>
    let xRange: ClosedRange<Int>
    let yRange: ClosedRange<Int>
    let positions: Set<Position>

    func hash(into hasher: inout Hasher) {
        hasher.combine(positions)
    }

    init(data: Set<Point>) {
        self.data = data
        self.xRange = data.map(\.x).range()
        self.yRange = data.map(\.y).range()
        self.positions = Set(data.map(\.position))
    }


    struct Point: Equatable, Hashable, CustomDebugStringConvertible {
        let x: Int
        let y: Int
        let val: V

        var debugDescription: String {
            "Point(x: \(x), y: \(y), val: \(val))"
        }
    }

    func adjacent(to point: Point) -> [Direction: [Point]] {
        let all = data.filter { $0.x == point.x || $0.y == point.y }
        return [
            .up: all.filter { $0.y < point.y }.sorted(by: { $0.y > $1.y }),
            .down: all.filter { $0.y > point.y }.sorted(by: { $0.y < $1.y }),
            .left: all.filter { $0.x < point.x }.sorted(by: { $0.x > $1.x }),
            .right: all.filter { $0.x > point.x }.sorted(by: { $0.x <  $1.x }),
        ]
    }
}

extension Grid {
    init(string: String) where V == Int {
        let lines = string
            .split(whereSeparator: \.isNewline)
            .map { $0.map { Int(String($0))! } }
        self.init(lines: lines)
    }

    init(data: [Point]) {
        self.init(data: Set(data))
    }

    init(lines: [[V]]) {
        self.init(data: lines
            .enumerated()
            .flatMap { y, line in
                line
                    .enumerated()
                    .map { x, val in
                        Point(x: x, y: y, val: val)
                    }
            }
        )
    }

}

extension Grid.Point {
    func distance(to other: Self) -> Int {
        return abs(other.x - self.x) + abs(other.y - self.y)
    }
}

enum Direction: Int, CaseIterable {
    case right, down, left, up
}

extension Direction {
    init?(from character: Character) {
        let map: [Character: Self] = [
            ">": .right,
            "v": .down,
            "<": .left,
            "^": .up
        ]
        guard let dir = map[character] else {
            return nil
        }
        self = dir
    }

    var inverted: Self {
        switch self {
        case .up: return .down
        case .down: return .up
        case .left: return .right
        case .right: return .left
        }
    }
}

extension Int {
    func times<T>(_ e: T) -> [T] {
        (0..<self).map { _ in e }
    }
}

struct Position: CustomStringConvertible, Hashable, Comparable {
    let x: Int
    let y: Int

    var description: String {
        "Position(x: \(x), y: \(y))"
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.x <= rhs.x && lhs.y <= rhs.y
    }
}

extension Position {
    func distance(to other: Self) -> Int {
        return abs(other.x - self.x) + abs(other.y - self.y)
    }

    func move(diff: Position) -> Self {
        Self(x: x + diff.x, y: y + diff.y)
    }
}

struct Grid2D {
    let positions: [Position]
}

struct Point3D: CustomDebugStringConvertible, Hashable {
    let x: Int
    let y: Int
    let z: Int

    var debugDescription: String {
        "Point3D(x: \(x), y: \(y), z: \(z))"
    }
}

extension Point3D {
    init(string: Substring) {
        let parts = string.split(separator: ",")
        self.init(
            x: Int(parts[0])!,
            y: Int(parts[1])!,
            z: Int(parts[2])!
        )
    }

    func distance(to other: Self) -> Int {
        return abs(other.x - self.x) + abs(other.y - self.y) + abs(other.z - self.z)
    }
}

struct Grid3D: Equatable {
    let points: [Point3D]

    func neighbours(to point: Point3D) -> [Point3D] {
        points.filter { $0.distance(to: point) == 1 }
    }
}

func plot(_ points: [(position: Position, symbol: String)]) {
    let allPositions = points.map(\.position)
    let xRange = allPositions.map(\.x).range()
    let yRange = allPositions.map(\.y).range()
    let description = yRange.map { y in
        let line = xRange
            .map { x in
                let position = Position(x: x, y: y)
                return points.last(where: { pos, _ in pos == position })?.symbol ?? "."
            }
            .joined()
        return "\(y)".padding(toLength: 5, withPad: " ", startingAt: 0) + line
    }
    .joined(separator: "\n")
    print(description)
}

extension Grid {
    func removeAll(where remove: (Point) -> Bool) -> Grid {
        Grid(data: data.filter { !remove($0) })
    }
}
extension Grid.Point {
    var position: Position {
        Position(x: x, y: y)
    }

    func move(in direction: Direction, step: Int = 1) -> Self {
        switch direction {
        case .up: return Self(x: x, y: y-step, val: val)
        case .down: return Self(x: x, y: y+step, val: val)
        case .left: return Self(x: x-step, y: y, val: val)
        case .right: return Self(x: x+step, y: y, val: val)
        }
    }
}

func plot(_ grid: Grid<Character>, extra: [(position: Position, symbol: String)] = []) {
    let points = grid.data.map { point in (Position(x: point.x, y: point.y), String(point.val)) }
    plot(points + extra)
}

extension Collection where Element == Int {
    func range() -> ClosedRange<Int> {
        (self.min()!)...(self.max()!)
    }
}

extension RangeReplaceableCollection {
    mutating func shift() -> Element {
        let element = removeFirst()
        self.append(element)
        return element
    }
}

func maximizeIterative<State: Hashable>(
    _ current: State,
    finished: @escaping (State) -> Bool,
    score: @escaping (State) -> Int,
    maximumPotentialScore: ((State) -> Int),
    candidates: (State) -> any Collection<State>
) -> [State] {
    var bestCandidate: (state: State, score: Int)?
    var toTest: [State] = [current]
    var tested = Set<Int>()

    var iterations = 0
    while !toTest.isEmpty {
        iterations += 1
        let bestKnownScore = bestCandidate?.score ?? -1
        let next = toTest.last!
        toTest.removeLast()
        if finished(next) {
            let score = score(next)
            if score > bestKnownScore {
                bestCandidate = (next, score)
            }
            continue
        }
        let nonTestedCandidates = candidates(next).filter { !tested.contains($0.hashValue) }
        toTest.append(contentsOf: nonTestedCandidates.filter { maximumPotentialScore($0) > bestKnownScore })
        tested.insert(next.hashValue)
        tested.formUnion(nonTestedCandidates.filter { maximumPotentialScore($0) <= bestKnownScore }.map(\.hashValue))
    }

    return [bestCandidate!.state]
}

func maximizeRecursive<State: Hashable>(
    _ current: State,
    finished: @escaping (State) -> Bool,
    score: @escaping (State) -> Int,
    maximumPotentialScore: ((State) -> Int)? = nil,
    candidates: (State) -> any Collection<State>
) -> [State] {
    var cache: [State: (chain: [State], score: Int)] = [:]
    var bestCandidate: (endState: State, score: Int)?

    func maximizeRecursiveWithCache(current: State) -> (chain: [State], score: Int)? {
        if let cached = cache[current] { return cached }
        let bestKnownScore = bestCandidate?.score ?? -1
        guard (maximumPotentialScore?(current) ?? Int.max) > bestKnownScore else { return nil }

        let score = score(current)
        guard !finished(current) else {
            if score > bestKnownScore {
                print("Found best candidate with score: \(score), cacheSize: \(cache.count)")
                bestCandidate = (current, score)
            }

            return ([current], score: score)
        }
        let candidates = candidates(current)
            .compactMap { candidate in
                maximizeRecursiveWithCache(current: candidate)
            }
        guard let bestChain = candidates.max(by: { $0.score < $1.score }) else {
            return ([current], score)
        }
        let result = (chain: [current] + bestChain.chain, score: bestChain.score)
        cache[current] = result
        return result
    }
    let res = maximizeRecursiveWithCache(current: current)
    print("Cache size: \(cache.count)")
    return res!.chain
}

struct Graph<T> {
    struct Edge: CustomDebugStringConvertible {
        let from: T
        let to: T
        let weight: Int

        var debugDescription: String {
            return "\(from) - [\(weight)] -> \(to)"
        }
    }
    let edges: [Edge]
}

func measure<T>(_ name: String? = nil, file: String = #file, line: Int = #line, block: () -> T) -> T {
    var res: T!
    let duration = ContinuousClock().measure {
        res = block()
    }
    let marker = name ?? "\(file):L\(line)"
    print("\(marker) took \(duration)")
    return res
}
