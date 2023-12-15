import Foundation
import Shared

private func positions<V>(after point: Position, direction: Direction, grid: Grid<V>) -> [Position] {
    switch direction {
    case .right:
        let range = grid.xRange.suffix(from: grid.xRange.firstIndex(of: point.x)!).dropFirst()
        return range.map { Position(x: $0, y: point.y) }
    case .down:
        let range = grid.yRange.suffix(from: grid.yRange.firstIndex(of: point.y)!).dropFirst()
        return range.map { Position(x: point.x, y: $0) }
    case .left:
        let range = grid.xRange.prefix(upTo: grid.xRange.firstIndex(of: point.x)!)
        return range.map { Position(x: $0, y: point.y) }.reversed()
    case .up:
        let range = grid.yRange.prefix(upTo: grid.yRange.firstIndex(of: point.y)!)
        return range.map { Position(x: point.x, y: $0) }.reversed()
    }
}

private func steps(grid: Grid<Character>, point: Grid<Character>.Point, direction: Direction) -> Int {
    let positions = positions(after: point.position, direction: direction, grid: grid)
    let points = positions.map { grid.points[$0]! }
    let toStop = points.prefix(while: { $0.val != "#" })
    let round = toStop.filter { $0.val == "O" }
    return toStop.count - round.count
}

private func tilt(grid: Grid<Character>, direction: Direction) -> Grid<Character> {
    let moves = grid.data
        .filter { $0.val == "O" }
        .sorted(by: { $0.position < $1.position })
        .map { point in
            let steps = steps(grid: grid, point: point, direction: direction)
            return (from: point.position, to: point.position.move(in: direction, step: steps))
        }

    let toAdd = Set(moves.map(\.to))
    let toRemove = Set(moves.map(\.from)).subtracting(toAdd)
    let toUpdate = toAdd.union(toRemove).map { grid.points[$0]! }

    let newData = grid.data.subtracting(toUpdate)
    + toAdd.map { position in
        return Grid<Character>.Point(x: position.x, y: position.y, val: "O")
    }
    + toRemove.map { position in
        return Grid<Character>.Point(x: position.x, y: position.y, val: ".")
    }

    let result = Grid(data: newData)
    return result
}

private func cycle(grid: Grid<Character>) -> Grid<Character> {
    [Direction.up, .left, .down, .right].reduce(grid, tilt(grid:direction:))
}

private func cycle(grid: Grid<Character>, cycles: Int) -> Grid<Character> {
    var grid = grid
    var solutions = [grid]
    var currentCycle = 0
    while currentCycle < cycles {
        grid = cycle(grid: grid)
        currentCycle += 1
        if currentCycle % 10 == 0 {
            print("Cycle: \(currentCycle)")
        }
        if let firstSeen = solutions.firstIndex(of: grid) {
            let metaCycleLength = currentCycle - firstSeen
            print("Found meta-cycle after: \(currentCycle), length: \(metaCycleLength)")
            let remaining = ((cycles - currentCycle) % metaCycleLength)
            print("Remaining: \(remaining)")
            return cycle(grid: grid, cycles: remaining)
        }
        solutions.append(grid)
    }
    return solutions.last!
}

private func load(grid: Grid<Character>) -> Int {
    let yMax = grid.yRange.upperBound + 1
    return grid.data.filter { $0.val == "O" }.map { yMax - $0.y }.sum
}

public let day14 = Solution(
    part1: { input in
        let grid = Grid(lines: input.split(whereSeparator: \.isNewline).map { $0.map { $0 }})
        let tilted = tilt(grid: grid, direction: .up)
        return load(grid: tilted)
    },
    part2: { input in
        let grid = Grid(lines: input.split(whereSeparator: \.isNewline).map { $0.map { $0 }})
        let cycles = 1000000000
        let cycled = cycle(grid: grid, cycles: cycles)
        plot(cycled)
        return load(grid: cycled)
    },
    testResult: (136, 64),
    testInput: """
O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....
""",
    input: """
O#...OO.#.#..##.#..#O.OO...O##OO.......#......O.O...O..........O..#O..O.#.#.O.....##O.#O.##.........
.OOO..OOO.O.#.....#.....#.#.....O..#..OO..#.....O#O##..##O#.OO....O##.OOO..O...#....O....#O..#...O..
OOO#...O#...##.OOOO##.O..#.....O...#.O..#...#.O..OO..##.#....O#O..#O#..##...O.OO..#.#........#O....O
O..#..#...#.O##.......OO#.#....O.##.O..O.O#.O..O#.....#...O..OO.O.#......O.###.........#.......##...
..O.O.O..#O..OOOO..#..#..O..O#O...O....#.O#........OOO#.O...O..O#.#.O........#......#O.O...OO.#.O..O
#..O.#..##....#...O..........#..O.#..##.O.....O.O.O..O..O.O.#.OO#.#..##.........#OO.O....##...#..##.
OO.O#.#.O...O..#..#OO..O.............O.........O.#.......#OO#.O.#OOO.##OOO..OO#.....O#.O.#O.O##OO...
.##...##O.....O..OO..O#.O.O.#....OOO.O.O#..#O#..#.O.OO...####O#......#.#O..O.O....#..O....#.#.#.O#.#
.....#O..O.O.#......#..........#.OO...O.#O.O.....O.#OO.#.#.O#......OO..O.O.....#...O.O..OO...#O.O#..
.O..#....#....OOO.O.#....O#O###....O.O#OO.............#...OOO.....#....O..O.......###............O..
..#O.#....###..O...#.....OO#O.....#....###..O#.......#OO....O.O...#....#.O.O.#..O.##O...O..O#...##..
O...O.#O.#O#....O.O#.......#............OO.....O.#O..O#O....O##O.OO..#..O..#O..O#O...##O.O.O.O#..O.#
O#.O......#.......O....#...O.....#O#.#..O...O.###O.OO#.........O.....O..O...#.#O.....OO#..O.#...#...
.#...O.......O.#.....O.......O.O..#....#..O#O.#..O.#..##.......##....O.#.....O........OO.O...O.....O
..O..#.#O.O#...#.......#O#OO.#O....O...#O..O.O.#O.OO#......OO#....#...O.#...#O.#...O.#.OO#..O.#OO.O#
.O.......O...#.......#....O..O......O.O.O#O.#O...O.#.....O..O...#OOO#..O...O##..OOO#....#..........O
OO#..##O.O.O.O.#....O#.O#O.##..O......#.#.O.O..O.O...OO#.......#..O.#O.O#.OO....#O#O.O.O.#.O#O#.....
#O#.O.......##OOO..OO...O#..#..O.O.##.O#....#OO....#...OO.#..#..O.......O#O.......#.O.O............O
..O.OO.O#..OOO....OO.O...#.#.......#.O.......O..OOO.##.##.#...#.O.....O..O.......O.O.#..............
OO#.....O.O.#.#...#.#.....O....#.#O..O......#..#..O...#.#....O#..OO....O.#.....O...O.#.O..#.........
....O.#.O...O#....#.O.#.......O#.#.O##......#...O.#..O#..#.#O.O...#.....O......#O#.#.#O....O..O.O#.#
.....###.O.O.O#.O.......O..OO#...#.#...#..O......#O....O...OOOO..O...#.#.#.#.O#..O.......OO.....#.#.
...O.O...#O..O..#..O#.O....#O..#..O...#.O.O.OO....#O#O#.OOO##..#O..OOO#.O.O..O....#...O#..O...#O....
.##.O...O..O.#.#OOO..O..O...O........#O.OO#..#OO......O....O.##...#..O#..O#...#..O.....O...##...O...
.O.#.O#OO.#...O....#.O.O..OO.O#O...O#..##...O.O...#...O#OOO.....O.........O......#.O.#...........OO.
O....O#O...#.OO#...#.........####..........O.#...#...O.O.O#.O..............##....O..O..O..#.#...##.#
..O.OO.#.OO#..O.#O....O......O.............#...##...#.O..#..O###.#......O..##.O.........O.#........O
O...#....#.......OO...O#O.......#.....#....OOO.#...OO.#O..O.#......#.##O....OO....O#.#.O..O...O..O..
...#...#....O.#..OOOO#..O#..#.##O.#.#.O..#.O....OOO....#..#..#....OOO...#.O.O...#.#.#O.O..O.#..O....
...O#.#...O.#.##O..O#..O.....OO#O...#.OO#..OO#O..OOO.O...#...O.#.O....O#...OOO..O...O....O....#.#..O
#........#..O.###.#...O#.O#O.........##..O.O.#O.O.###O....##.#.#.#..O.#O....#OO#O.....O.........O.##
O.O....#O.....O#...O#.....O##.OOO.#O.O..O....O..O...O....#...O.........O.#.O..#.#.O.O#O...#.#...O..O
.O..O##.O........O.OOO#O...#....O.OOOO#O..O..............O..O.O.O...#..........#......O..O.O.#......
.O....#OO#OO...#...O.##O.....#O.#.O.O...O.....OO#.O.......O#...#O..O#OOO.........##.....##...#...##O
.O#..OO....OOO..#.......OOO...##....OO..O.O..........##...#.#...#....O..#....O..........#.#.#O#.#.O.
##.......#O...O#.OO.#..O.O.O....#........#.O..........O.O.O..O.....#.OO#...#O#.O.OO..OO.O#..##....O.
....#..#..#O.##O.#....#.#.OO.......##..O#.#.##......O.O.OO..##...O.#....#..O.#....#.O....#...#O..O..
..O....#...OOO.#O..#..#...O..OOO..O#..#O......#..O...#.O..O.....#O...O#......#.......#O.O.........O#
#.OO....O....###....#OOO..O.#..#........#OO.....#O..........#O...#..O.OO..#......##O..O##.........#.
....#..O..........O.#.#..O.O.#....O..O....O..OO#....O.......OOO.....O.O.O..#....#.....O.O#.O#.##..O.
#.O...OO..#....O.O..O...#O..O#.#O.#...O.....##..O...O##...O........#O..#O..O#.O.#.......O#.#...#.OO#
.#.OOO#....#..O........OO....O#..###.O....O...O...O#.#O..#.OO........##..#..#...O..#.......OO...O#..
.....OOO.#.O....O....#....O..O.O.O.O....O...#OO....#.OO#OO...O.OOOO.O...O.O....#OO...#O.#O..O....#..
.#.#..........#O..OOO...#..O...#.............OO....#O...O#..O...#........O..#O#....OO.....OO##.O...#
..OOO.OOO##.##O#...O.O..O......O#O..O##...##....O.#........O....##...O#O..O#.O...O.O...O....O.......
..###.OO#..#.O.#....#..O..OO..O.###....O....#..O.O#.#......OO.....O#....O.OO....OO.O.O.O#........O..
#O###.#......O......O......#...O#.O.O...O#OO.O#....O..#..O#.OO...O..O..#..#.#...#..##OO...OO....O..O
..O...#..#O##O...#..#.#OO........O.#....O....................#...........#.....O..#...O#.#.O.O..#.#.
O...#.O...#O..#..O.O.#.....O.#....O.O...##......#..#..OO...#..O..OOOOO..O..O...#..O.OO...O.O#O.#....
........#...O.#.....O.O..O....#....#O......#..#........#O#.....#O##..OO.O...#......#OO.O#.O........O
.O..##..O#....#....OO.#O.#O#OO#O.#..OOO#.......OO....O.#.....O....#..#..##...#O.....#....O..O....O..
...##O..O.#.O..#.O.....#..O#.##OO#O#...O.##..#..#......O.##O.OO...O.#..#.O....#..O....O.O.........#.
...O..O.#..O.#O#......O.#OO.O.##.##..O###.#.O........O..O..O#...#.O...O.....##....O.OO..#..O..#..O#.
O....O......#..#O#.O....O...O.....#.O##O.O...#O.#O...O...#O...O.O#O...#O.#.#....#.#.#O....O.....OO..
.O.##..###....OO................OOO.....#.#.OO.O...O#.OO.#..O........#...O.O#.O..O.O..O.O...O....O..
...OOOO..O.#..O.#...O.##.O.O##.#..O.##..#.....##....O.O....O.O.##O.OO.#O.........#.##.O#...O.O..O...
...O.O..#O.#..OO.#.#O#OO..#OO.O......O.O.OO....#..OO.......#O..O.##....O.O..##O#.#....OO.....#.O...#
OO.....O....#O...O#.#..O...O#.#.O..#OO....O..#..OOO...O.........O....#.###O.OO....O....O............
..O..O.....#O.#O#OO..##.O.........#..##.##.O..O#O#..O.O..O..O...###.....OO.......#.##..#O##..O#O..O.
#O.#O...OOOO.O.###....#O..#O#O#.OO.....#O..#..#...O.#O.....#O....###.O....#..O...O..O....#......#...
O##...#.....#..O.#.O.#.......#..O#.....#.O.O.#...O..O....OO.....#.O###.#.....OO....#OO..OOO..#......
..O......#...#O..OO#O#OO....O.O.OOO.#O.OO.O......#....O##..O#.OO.##.#...O.##.....#...####.......##..
.......OO#.O.O.#.O.......#O#........#O..##OO#.#O..##..OO.##OO....#..O......#..#.O..#...#.O.....OO...
###.OO.O.O#..O.......#OO#.....#..O.O..O.O.......#..#O.##..#O..#..#...#O#......OO##O#OOO#...O#....O.#
#O#.O.........#..O.#..#..#..............O..O..#..O##....O.##..O..O#..O.....#OO..O.#.......O....OO...
#O#O....O#.#.O..O..#...#..#.#...#O.....O..##..#....O#.#.O.O.O...O.#...#.O....O#....#.....#.#..#...#O
O...O........O.#..OOOO..#...O#O....##.O..#.......#..O..#..#O.#...OO..#.O..##..#...O#O.##.....#..#.O.
O..#.##.......O..O......#..#.#.O...O#.O.......O#.O.O#O..#.O#.OOOOO.#OO.#.OO#....O....#...O####OO...#
#O..O....O..#O..O.OO.#.O.##...#O#.....O...#.....#......##......O#O#.........#..#.O...O.O..........#.
OOO.#.O.....O..OO.O#.#..#.#..#.............O#.......OOO#OO.O.#.#O...O.#..#...#..O...#.O#....O..O..##
OO#........#.O.O....O#O...#O.#..#.#...#......##.......#..#..#.#.#.......O...##...O#...O..O.......O..
O..#O......O....#O.O#..O........#......##..#...#O...OO....#.#...O........O.#O.......O.....O...#..O..
..#O#.......O..O..O..........#...OO.#..OOO....O....#OOO#..O.....#.O#....O...#O.......#..#.O...#..##.
...#O...O.OOO...O#.....#..#....##..#....#OO..O.OO#O.O#..#.O#O#O.....#OO#O...#.#O......O.....OO.....O
..#...O.O.....O...O##O..O.....O..O..#O.O..O....O.#O....#O....O..O.O......O.....#..#....O......#.....
O.#...O..#O.#...O.O.O..#..##...O.O..O#..O...O#....O........O#O.#O.#.O.......#.O.O..O.......OO.#.....
O#...O.O#..#O#...............OO##.#..#...#O....O....#O.OO.O..O#.O.....#O.....O..O...#..#..#...#..O.O
....OO.O#.#.......O..O.O.#..#.O#.O.....#............#....O..O..O..O.O..#..#..O.....#O.#O.#.O...O..#O
.....#...OOO...#.O....O#...#.....O..OO....##O.OOO..#.O...#...O.##.O#O...O.....#.#...O...O.##.#.....O
....##...O#O..O...##O.OOOO...#.#.....OOO..........O.O....O.#O.#..O#..O###...O....#.O#O......OOO..O.O
#..#...OO##OOO.O#....#O#.O.....O#.#...##.#O..OO.#.#.O.O..OO.O#.........##.....O..O#..O......O.....##
..O..OO.##O.##OO...O#.....#O.O..........#.#.......#..#..O....O...#......#..O.#.#...#.....#OO........
O.......#O.....O....OO#.#..O.....OO..#..OOO.O....O##O#O.O....OO#......#.#.O......#.OO.O.#OO....#....
....O...#.O....##.OO.....#O#.O...O....O#.O##.....O.#.O#........OO##...O..#.....O...O.....O...#..O#O.
#.OO.#.O##....#..O....O..#...OO...#....#.##...OO....#O.........O..#......O.OO..#..#..##......#O...#.
O...#.O.##..#.#OO#.O#.O###.O.#...O#..O###.......#....O.#.........O..O..#O#..O.O.O..OO..#.#...O#..O..
......#..##..#..##...O#......#..#.#O#.....#.#.O...#.#O..#O..O.O.#..O.O.O....O....#....OO.#O......#.O
..OO.##.#....O.O...O.#.....##O..#....#..OO#.#...##......#...OO...#.....#...#O..#O...#O......O#...O#.
OOO.O##O...O..O.O#.##O#..OO.#.O..O...O.#O..O..#.#...O.O.......#O##.#..#.#.O.......O..OOO#.O....O#..O
...O...OO.O...OO...O.....O#.#.#O.O.O.O..O..O...OO....O..###...##....#O....O...#.#.##....O....#O.O..#
......#OO.........##.O...#..#.O.#..OO....O..O..O.#OO......OO.O#.......O...#..O.O#..OO.##.##.OOOOO...
........O.....##..O.OO..O#.....O................O........OO#...##.....O#....#...#O.O..O...#.##..#O.O
#OO.O.O.O.O#.OOO....#O#.#....#...#O#O.#.....OOO.....#.O..##.O##..O...........#......#...O.#.#.O.....
.#O.........#.O.##O..#..O.O...OO..#..O.O#OO#..#O.O.O....#......O.....OO#..OO#.O.O..#.#.#OO.#..O.....
...OO.O#O.O#.O.......O#..#OO.O.OO..O#.O.OO.O........O.OO..#..O...#.#.#....#.#.....OO.#.O..OO.....#..
###.....O..#...OO.#OO........O....#O#OO...#.O...#.....#O...#.##..O..#O#..O##.O#.O.....#.O....#O...#.
#O#.##......O....#.O##..#.......#.#..O......O.OOO.#....O##.#.O..OO...O..#...#.###......OO....O#.#.O#
#OOOO#.#...OO..O..O..#..O..O...#OO.O.O.O#.#.##..#....####..O#....#O.OOO..O#O.#...O....#.O......O....
.##OO....#......O..OOO......#..O.....#..O...O..#.#.........OO.O..##.......#.#O#.OO......O#O..O......
........OOO.....OO........O.O.O.#O...#...O...O...O..O..#.....#O..#.#..OO....O...#..##..#O......O.#O#
"""
)
