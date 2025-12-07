import Algorithms
import Shared

private func part1(input: String) -> Int {
    let grid = Grid(string: input)
    let start = grid.data.first { $0.val == "S" }!
    let splitters = grid.data.filter { $0.val == "^" }
    let beamStart = start.position.move(in: .down)
    let beam = grid.yRange.reduce([beamStart]) { beam, y in
        let beams =
            beam
            .filter { $0.y == y }
            .map { $0.move(in: .down) }
            .flatMap { b in
                if splitters.contains(where: { $0.position == b }) {
                    return [b.move(in: .left), b.move(in: .right)]
                } else {
                    return [b]
                }
            }
            .uniqued()
        return beam + Array(beams)
    }
    // plot(grid, extra: beam.map { ($0, "|") })
    let splits = beam.filter {
        let below = $0.move(in: .down)
        return splitters.contains(where: { $0.position == below })
    }
    return splits.count
}

private func part2(input: String) -> Int {
    let grid = Grid(string: input)
    let start = grid.data.first { $0.val == "S" }!
    let splitters = grid.data.filter { $0.val == "^" }
    let beamStart = start.position.move(in: .down)
    let beam = grid.yRange.reduce([(pos: beamStart, cardinality: 1)]) { beam, y in
        let beams =
            beam
            .filter { $0.pos.y == y }
            .map { (pos: $0.pos.move(in: .down), cardinality: $0.cardinality) }
            .flatMap { (b: (Position, Int)) in
                if splitters.contains(where: { $0.position == b.0 }) {
                    return [(b.0.move(in: .left), b.1), (b.0.move(in: .right), b.1)]
                } else {
                    return [b]
                }
            }
        let grouped = beams.grouped(by: { $0.0 }).map { ($0, $1.map(\.1).sum) }
        return beam + grouped
    }
    let ends = beam.filter { $0.pos.y == grid.yRange.upperBound }
    return ends.map(\.cardinality).sum
}

public let day7 = Solution(
    name: "day7",
    part1: part1,
    part2: part2
)
