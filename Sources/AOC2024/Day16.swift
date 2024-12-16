import Shared

private func part1(input: String) -> Int {
    let grid = Grid(string: input)
    let start = State(
        pos: grid.data.first { $0.val == "S" }!.position, 
        dir: Direction.right, 
        cost: 0
    )
    let end = grid.data.first { $0.val == "E" }!.position
    let path = bestPath(start: start, end: end, grid: grid)
    return path!.map(\.cost).sum
}

private func part2(input: String) -> Int {
    let grid = Grid(string: input)
    let start = State(
        pos: grid.data.first { $0.val == "S" }!.position, 
        dir: Direction.right, 
        cost: 0
    )
    let end = grid.data.first { $0.val == "E" }!.position

    func findBestPaths(start: State, maxCost: Int) -> [[State]] {
        start.possibilities(in: grid)
            .flatMap { s -> [[State]] in 
                guard let path = bestPath(start: s, end: end, grid: grid),
                    path.map(\.cost).sum <= maxCost
                else {
                    return []
                }
                if let fork = path.firstIndex(where: { $0.possibilities(in: grid).count > 1 }) {
                    let beforeFork = [start] + path.prefix(upTo: fork)
                    return findBestPaths(start: path[fork], maxCost: maxCost - beforeFork.map(\.cost).sum)
                        .map { path in
                            beforeFork + path
                        }
                } else {
                    return [[start] + path]
                }
            }
    }

    let best = part1(input: input)

    let paths = findBestPaths(start: start, maxCost: best)
    let withCost = paths.map { path in (path.map(\.cost).sum, path) }
    let lowestCost = withCost.map(\.0).min()!
    let tiles = Set(withCost.filter { $0.0 == lowestCost }.map(\.1).flatMap { $0.map(\.pos) })
    // 537 is incorrect
    // 437 is incorrect
    // 478 is incorrect
    // 466 is incorrect
    // 440 is incorrect
    return tiles.count
}

private func bestPath(start: State, end: Position, grid: Grid<Character>) -> [State]? {
    return aStar(start: start) { s in
        s.pos == end
    } estimatedCostToFinish: { s in
            s.pos.distance(to: end)
        } candidates: { (s: State) -> [(State, Int)] in
            s.possibilities(in: grid)
                .map { s in
                    (s, s.cost)
                }
    }
}

private struct State: Hashable {
    let pos: Position
    let dir: Direction
    let cost: Int

    func possibilities(in grid: Grid<Character>) -> [State] {
        return [
            State(pos: pos.move(in: dir), dir: dir, cost: 1),
            State(pos: pos.move(in: dir.rotate(.left)), dir: dir.rotate(.left), cost: 1001),
            State(pos: pos.move(in: dir.rotate(.right)), dir: dir.rotate(.right), cost: 1001),
        ]
            .filter { c in 
                grid.points[c.pos]!.val != "#"
            }
    }
}

public let day16 = Solution(
    name: "day16",
    part1: part1,
    part2: part2
)
