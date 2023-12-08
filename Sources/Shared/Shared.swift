import Foundation

public func zip3<A, B, C>(_ a: some Sequence<A>, _ b: some Sequence<B>, _ c: some Sequence<C>) -> some Sequence<(A, B, C)> {
    zip(zip(a, b), c).map { aAndB, c in (aAndB.0, aAndB.1, c) }
}

public extension Collection where Element: Numeric {
    var sum: Element {
        reduce(0, +)
    }
}

public extension Collection {
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

public extension ClosedRange {
    func fullyContains(_ other: ClosedRange) -> Bool {
        lowerBound <= other.lowerBound && upperBound >= other.upperBound
    }
}

public extension ClosedRange where Bound: Numeric {
    func expanded(by size: Bound) -> Self {
        Self(uncheckedBounds: (lowerBound - size, upperBound + size))
    }

    func shrinked(by size: Bound) -> Self {
        Self(uncheckedBounds: (lowerBound + size, upperBound - size))
    }
}

public extension Range where Bound: Numeric {
    /// Offsets a range by moving lower + upper bound by specified offset
    func offset(by offset: Bound) -> Self {
        Self(uncheckedBounds: (lowerBound + offset, upperBound + offset))
    }

    /// Returns the range(s) that result from removing ``other`` from ``self``, should return one or two ranges
    func difference(from other: Self) -> [Self] {
        let inner = self.clamped(to: other)
        if inner.isEmpty {
            return [self]
        } else {
            // Return two ranges, one before the overlap, and one after
            return [
                Range(uncheckedBounds: (self.lowerBound, inner.lowerBound)),
                Range(uncheckedBounds: (inner.upperBound, self.upperBound))
            ]
                .filter {
                    // A lot of cases will result in empty ranges, get rid of these
                    !$0.isEmpty
                }
        }
    }
}

public struct Grid<V>: Hashable where V: Equatable, V: Hashable {
    public let data: Set<Point>
    public let xRange: ClosedRange<Int>
    public let yRange: ClosedRange<Int>
    public let positions: Set<Position>

    public func hash(into hasher: inout Hasher) {
        hasher.combine(positions)
    }

    public init(data: Set<Point>) {
        self.data = data
        self.xRange = data.map(\.x).range()
        self.yRange = data.map(\.y).range()
        self.positions = Set(data.map(\.position))
    }


    public struct Point: Equatable, Hashable, CustomDebugStringConvertible {
        public let x: Int
        public let y: Int
        public let val: V

        public init(x: Int, y: Int, val: V) {
            self.x = x
            self.y = y
            self.val = val
        }

        public var debugDescription: String {
            "Point(x: \(x), y: \(y), val: \(val))"
        }
    }

    public func adjacent(to point: Point) -> [Direction: [Point]] {
        let all = data.filter { $0.x == point.x || $0.y == point.y }
        return [
            .up: all.filter { $0.y < point.y }.sorted(by: { $0.y > $1.y }),
            .down: all.filter { $0.y > point.y }.sorted(by: { $0.y < $1.y }),
            .left: all.filter { $0.x < point.x }.sorted(by: { $0.x > $1.x }),
            .right: all.filter { $0.x > point.x }.sorted(by: { $0.x <  $1.x }),
        ]
    }
}

public extension Grid {
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

public extension Grid.Point {
    func distance(to other: Self) -> Int {
        return abs(other.x - self.x) + abs(other.y - self.y)
    }
}

public enum Direction: Int, CaseIterable {
    case right, down, left, up
}

public extension Direction {
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

public extension Int {
    func times<T>(_ e: T) -> [T] {
        (0..<self).map { _ in e }
    }
}

public struct Position: CustomStringConvertible, Hashable, Comparable {
    public let x: Int
    public let y: Int

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    public var description: String {
        "Position(x: \(x), y: \(y))"
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.x <= rhs.x && lhs.y <= rhs.y
    }
}

public extension Position {
    func distance(to other: Self) -> Int {
        return abs(other.x - self.x) + abs(other.y - self.y)
    }

    func move(diff: Position) -> Self {
        Self(x: x + diff.x, y: y + diff.y)
    }

    func move(in direction: Direction, step: Int = 1) -> Self {
        switch direction {
        case .up: return Self(x: x, y: y-step)
        case .down: return Self(x: x, y: y+step)
        case .left: return Self(x: x-step, y: y)
        case .right: return Self(x: x+step, y: y)
        }
    }
}

struct Grid2D {
    let positions: [Position]
}

public struct Point3D: CustomDebugStringConvertible, Hashable {
    public let x: Int
    public let y: Int
    public let z: Int

    public init(x: Int, y: Int, z: Int) {
        self.x = x
        self.y = y
        self.z = z
    }

    public var debugDescription: String {
        "Point3D(x: \(x), y: \(y), z: \(z))"
    }
}

public extension Point3D {
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

public struct Grid3D: Equatable {
    public let points: [Point3D]

    public init(points: [Point3D]) {
        self.points = points
    }

    public func neighbours(to point: Point3D) -> [Point3D] {
        points.filter { $0.distance(to: point) == 1 }
    }
}

public func plot(_ points: [(position: Position, symbol: String)]) {
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

public extension Grid {
    func removeAll(where remove: (Point) -> Bool) -> Grid {
        Grid(data: data.filter { !remove($0) })
    }
}

public extension Grid.Point {
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

public func plot(_ grid: Grid<Character>, extra: [(position: Position, symbol: String)] = []) {
    let points = grid.data.map { point in (Position(x: point.x, y: point.y), String(point.val)) }
    plot(points + extra)
}

public extension Collection where Element == Int {
    func range() -> ClosedRange<Int> {
        (self.min()!)...(self.max()!)
    }
}

public extension RangeReplaceableCollection {
    @discardableResult
    mutating func shift() -> Element {
        let element = removeFirst()
        self.append(element)
        return element
    }
}

public func maximizeIterative<State: Hashable>(
    _ current: State,
    finished: @escaping (State) -> Bool,
    score: @escaping (State) -> Int,
    maximumPotentialScore: ((State) -> Int),
    log: (String) -> Void = { _ in },
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
        if iterations % 100 == 0 {
            log("Iteration: \(iterations), tested: \(tested.count), toTest: \(toTest.count), best: \(bestKnownScore)")
        }
    }

    return [bestCandidate!.state]
}

public func maximizeRecursive<State: Hashable>(
    _ current: State,
    finished: @escaping (State) -> Bool,
    score: @escaping (State) -> Int,
    candidates: (State) -> any Collection<State>
) -> [State] {
    var cache: [State: [State]] = [:]

    func maximizeRecursiveWithCache(current: State) -> [State] {
        if let cached = cache[current] { return cached }

        guard !finished(current) else { return [current] }
        let candidates = candidates(current)
            .compactMap { candidate in
                maximizeRecursiveWithCache(current: candidate)
            }
        guard let bestChain = candidates.max(by: { score($0.last!) < score($1.last!) }) else {
            return [current]
        }
        let result = [current] + bestChain
        cache[current] = result
        return result
    }
    let res = maximizeRecursiveWithCache(current: current)
    print("Cache size: \(cache.count)")
    return res
}

public struct Graph<T> {
    public struct Edge: CustomDebugStringConvertible {
        public let from: T
        public let to: T
        public let weight: Int

        public init(from: T, to: T, weight: Int) {
            self.from = from
            self.to = to
            self.weight = weight
        }

        public var debugDescription: String {
            return "\(from) - [\(weight)] -> \(to)"
        }
    }
    public let edges: [Edge]

    public init(edges: [Edge]) {
        self.edges = edges
    }
}

public func measure<T>(_ name: String? = nil, file: String = #file, line: Int = #line, block: () -> T) -> T {
    var res: T!
    let duration = ContinuousClock().measure {
        res = block()
    }
    let marker = name ?? "\(file):L\(line)"
    print("\(marker) took \(duration)")
    return res
}

/// Returns the Greatest Common Divisor of two numbers.
public func gcd(_ x: Int, _ y: Int) -> Int {
    var a = 0
    var b = max(x, y)
    var r = min(x, y)

    while r != 0 {
        a = b
        b = r
        r = a % b
    }
    return b
}

/// Returns the least common multiple of two numbers.
public func lcm(_ x: Int, _ y: Int) -> Int {
    return x / gcd(x, y) * y
}

extension Collection where Element == Int {
    /// Returns the least common multiple of all numbers in this collection
    public func leastCommonMultiple() -> Element {
        self.reduce(1, lcm)
    }
}
