import Shared

public func day15() {
//    print(part1(input: test, row: 10))
//    print(part1(input: input, row: 2_000_000))
//    print(part2(input: test, max: 20))
    print(part2(input: input, max: 4_000_000))
}

private func part1(input: String, row: Int) -> Int {
    let sensors = Sensor.create(input: input)
    let extremes = sensors.map(\.outerCoverage).reduce(Set()) { $0.union($1) }
    let xRange = extremes.map(\.x).range()
    let atRow = xRange.map { Position(x: $0, y: row) }
    print("Candidate positions: \(atRow.count)")
    let beaconFreePositions = atRow
        .filter { position in
            let canHaveBeacon = !sensors.contains(where: { sensor in sensor.covers(position) && sensor.closestBeacon != position })
            return !canHaveBeacon
        }
    return beaconFreePositions.count
}

private func part2(input: String, max: Int) -> Int {
    let sensors = Sensor.create(input: input)
    let validRange = 0...max
    var distressBeacon: Position!
    for row in validRange {
        if row % 1000 == 0 {
            print("Checking row: \(row)")
        }
        let coverages = sensors.compactMap { $0.coverage(at: row) }.merged()
        if coverages.count > 1 {
            let gaps = coverages.reduce([]) { acc, range in
                acc + [range.upperBound + 1]
            }.filter(validRange.contains(_:))
            assert(gaps.count == 1)
            distressBeacon = Position(x: gaps.first!, y: row)
        }
    }
    return distressBeacon.x * 4000000 + distressBeacon.y
}

private struct Sensor: CustomDebugStringConvertible {
    let position: Position
    let closestBeacon: Position
    private var distance: Int { position.distance(to: closestBeacon) }

    var outerCoverage: Set<Position> {
        let distance = position.distance(to: closestBeacon)
        let candidates = [-distance, distance].flatMap { xDiff in
            [-distance, distance].map { yDiff in
                Position(x: position.x + xDiff, y: position.y + yDiff)
            }
        }
        return Set(candidates)
    }

    func coverage(at row: Int) -> ClosedRange<Int>? {
        let yDistance = abs(position.y - row)
        guard yDistance <= distance else { return nil }
        let coverageWidth = distance - yDistance
        return (position.x - coverageWidth)...(position.x + coverageWidth)
    }

    func covers(_ other: Position) -> Bool {
        return position.distance(to: other) <= distance
    }

    var debugDescription: String {
        "Sensor at: \(position), closest beacon at: \(closestBeacon)"
    }

    static func create(input: String) -> [Self] {
        return Array(
            input
                .split(whereSeparator: \.isNewline)
                .map { line in
                    let parts = line.split(separator: "=").dropFirst().map { part in
                        if part.contains(where: \.isWhitespace) {
                            return part.split(whereSeparator: \.isWhitespace)[0].dropLast()
                        } else {
                            return part
                        }
                    }
                    .map { Int($0)! }
                    return Sensor(
                        position: Position(x: parts[0], y: parts[1]),
                        closestBeacon: Position(x: parts[2], y: parts[3])
                    )
                }
        )
    }
}

extension Array where Element == ClosedRange<Int> {
    func merged() -> [ClosedRange<Int>] {
        var result: [ClosedRange<Int>] = []
        for range in self.sorted(by: { $0.lowerBound < $1.lowerBound }) {
            if let last = result.last {
                if last.contains(range.lowerBound - 1) || last.overlaps(range) {
                    _ = result.popLast()
                    result.append(
                        (Swift.min(last.lowerBound, range.lowerBound))...Swift.max(last.upperBound, range.upperBound)
                    )
                } else {
                    result.append(range)
                }

            } else {
                result.append(range)
            }

        }
        return result
    }
}

private let test = """
Sensor at x=2, y=18: closest beacon is at x=-2, y=15
Sensor at x=9, y=16: closest beacon is at x=10, y=16
Sensor at x=13, y=2: closest beacon is at x=15, y=3
Sensor at x=12, y=14: closest beacon is at x=10, y=16
Sensor at x=10, y=20: closest beacon is at x=10, y=16
Sensor at x=14, y=17: closest beacon is at x=10, y=16
Sensor at x=8, y=7: closest beacon is at x=2, y=10
Sensor at x=2, y=0: closest beacon is at x=2, y=10
Sensor at x=0, y=11: closest beacon is at x=2, y=10
Sensor at x=20, y=14: closest beacon is at x=25, y=17
Sensor at x=17, y=20: closest beacon is at x=21, y=22
Sensor at x=16, y=7: closest beacon is at x=15, y=3
Sensor at x=14, y=3: closest beacon is at x=15, y=3
Sensor at x=20, y=1: closest beacon is at x=15, y=3
"""

private let input = """
Sensor at x=2662540, y=1992627: closest beacon is at x=1562171, y=2000000
Sensor at x=3577947, y=3994226: closest beacon is at x=3468220, y=3832344
Sensor at x=34015, y=3658022: closest beacon is at x=-48386, y=3887238
Sensor at x=3951270, y=2868430: closest beacon is at x=3499312, y=2620002
Sensor at x=3136779, y=3094333: closest beacon is at x=2731027, y=3076619
Sensor at x=3415109, y=2591103: closest beacon is at x=3499312, y=2620002
Sensor at x=277465, y=3971183: closest beacon is at x=-48386, y=3887238
Sensor at x=3697201, y=1834735: closest beacon is at x=3499312, y=2620002
Sensor at x=874397, y=1535447: closest beacon is at x=1562171, y=2000000
Sensor at x=2996230, y=3508199: closest beacon is at x=3251079, y=3709457
Sensor at x=2754388, y=3147571: closest beacon is at x=2731027, y=3076619
Sensor at x=524580, y=2640616: closest beacon is at x=-73189, y=1870650
Sensor at x=2718599, y=3106610: closest beacon is at x=2731027, y=3076619
Sensor at x=2708759, y=3688992: closest beacon is at x=3251079, y=3709457
Sensor at x=2413450, y=3994713: closest beacon is at x=3251079, y=3709457
Sensor at x=1881113, y=495129: closest beacon is at x=1562171, y=2000000
Sensor at x=3792459, y=3827590: closest beacon is at x=3468220, y=3832344
Sensor at x=3658528, y=641189: closest beacon is at x=4097969, y=-110334
Sensor at x=1379548, y=3381581: closest beacon is at x=1562171, y=2000000
Sensor at x=3480959, y=3069234: closest beacon is at x=3499312, y=2620002
Sensor at x=3871880, y=3531918: closest beacon is at x=3468220, y=3832344
Sensor at x=2825206, y=2606984: closest beacon is at x=2731027, y=3076619
Sensor at x=3645217, y=2312011: closest beacon is at x=3499312, y=2620002
Sensor at x=3485320, y=3509352: closest beacon is at x=3468220, y=3832344
Sensor at x=56145, y=3879324: closest beacon is at x=-48386, y=3887238
Sensor at x=148776, y=433043: closest beacon is at x=-73189, y=1870650
Sensor at x=3368682, y=3929248: closest beacon is at x=3468220, y=3832344
Sensor at x=3330787, y=2481990: closest beacon is at x=3499312, y=2620002
Sensor at x=2802875, y=3209067: closest beacon is at x=2731027, y=3076619
Sensor at x=2679788, y=3102108: closest beacon is at x=2731027, y=3076619
Sensor at x=3326846, y=3767097: closest beacon is at x=3251079, y=3709457
Sensor at x=3111518, y=1310720: closest beacon is at x=3499312, y=2620002
"""
