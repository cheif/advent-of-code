import Shared

private func part1(input: String) -> Int {
    let grid = Grid(string: input)
    let regions = grid.findRegions()
    let points = regions.map { r in
        r.count * r.perimeter.count
    }
    return points.sum
}

private func part2(input: String) -> Int {
    let grid = Grid(string: input)
    let regions = grid.findRegions()
    let points = regions.map { r in
        var perimeter = r.perimeter.sorted(by: { $0.position < $1.position })
        var sides: [[(Position, Direction)]] = []
        while !perimeter.isEmpty {
            let next = perimeter.removeFirst()
            let neigbours = [
                (next.0.move(in: next.1.rotate(.left)), next.1),
                (next.0.move(in: next.1.rotate(.right)), next.1),
            ]

            let sideIndex = sides.firstIndex(where: { side in
                side.contains(where: { s in neigbours.contains { $0 == s }})
            })
            if let sideIndex {
                sides[sideIndex].append(next)
            } else {
                sides.append([next])
            }
        }

        return r.count * sides.count
    }
    // 801946 too low
    // 842172 too high
    return points.sum
}

public let day12 = Solution(
    name: "day12",
    part1: part1,
    part2: part2
)
