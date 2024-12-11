import Algorithms
import Shared

private func part1(input: String) -> Int {
    let grid = Grid<Int>(data: Grid(string: input).data.map { Grid<Int>.Point(x: $0.x, y: $0.y, val: Int(String($0.val))!) })
    let heads = grid.data.filter { $0.val == 0 }.sorted { $0.y < $1.y }
    let visited = heads.flatMap { point in paths(grid: grid, start: point) }
    let unique = Set(visited.map { $0.prefix(1) + $0.suffix(1) })
    return unique.count
}

private func part2(input: String) -> Int {
    let grid = Grid<Int>(data: Grid(string: input).data.map { Grid<Int>.Point(x: $0.x, y: $0.y, val: Int(String($0.val))!) })
    let heads = grid.data.filter { $0.val == 0 }.sorted { $0.y < $1.y }
    let visited = heads.flatMap { point in paths(grid: grid, start: point) }
    return visited.count
}

func paths(grid: Grid<Int>, start: Grid<Int>.Point) -> [[Grid<Int>.Point]] {
    if start.val == 9 {
        return [[start]]
    }
    let neighbours = grid.neighbours(to: start).values.filter { $0.val == start.val + 1 }
    return neighbours
        .flatMap { n in paths(grid: grid, start: n) }
        .map { [start] + $0 }
}

public let day10 = Solution(
    name: "day10",
    part1: part1,
    part2: part2
)
