import Algorithms
import Shared

private func part1(input: String) -> Int {
    let positions = Set(input.split(whereSeparator: \.isNewline).map { Point3D(string: $0) })

    let iterations = positions.count > 20 ? 1000 : 10

    let withDistances = positions.withIndividualDistances()
        .prefix(iterations)
    let initial: [Set<Point3D>] = []
    let circuits = withDistances.reduce(into: initial) { acc, candidate in

        let toMerge = acc.filter({
            !$0.intersection(candidate.1).isEmpty
        })
        if !toMerge.isEmpty {
            var merged = candidate.1
            for mySet in toMerge {
                merged.formUnion(mySet)
                acc.removeAll(where: { $0 == mySet })
            }
            acc.append(merged)
        } else {
            acc.append(candidate.1)
        }
    }
    .sorted { $0.count > $1.count }
    return circuits.map(\.count).prefix(3).reduce(1, *)
}

private func part2(input: String) -> Int {
    let positions = Set(input.split(whereSeparator: \.isNewline).map { Point3D(string: $0) })

    var withDistances = positions.withIndividualDistances()
    let initial: [Set<Point3D>] = []
    var joinsAll: Set<Point3D>?
    var circuits = initial
    while joinsAll == nil {
        let candidate = withDistances.removeFirst()
        let toMerge = circuits.filter({
            !$0.intersection(candidate.1).isEmpty
        })
        if !toMerge.isEmpty {
            var merged = candidate.1
            for mySet in toMerge {
                merged.formUnion(mySet)
                circuits.removeAll(where: { $0 == mySet })
            }
            circuits.append(merged)
        } else {
            circuits.append(candidate.1)
        }
        if circuits.count == 1 && circuits[0] == positions {
            joinsAll = candidate.1
        }
    }
    return joinsAll!.map(\.x).reduce(1, *)
}

extension Set<Point3D> {
    func withIndividualDistances() -> [(Double, Self)] {
        self
            .combinations(ofCount: 2)
            .map { points in
                (points[0].euclideanDistance(to: points[1]), Set(points))
            }
            .sorted { $0.0 < $1.0 }
    }
}

public let day8 = Solution(
    name: "day8",
    part1: part1,
    part2: part2
)
