import Shared

public func day24() {
    //print(part1(input: input))
    print(part2(input: input))
    // 308 is too high
}

private func part1(input: String) -> Int {
    var grid = Grid(lines: input
                        .split(whereSeparator: \.isNewline)
                        .map { line in line.map { $0 }}
    )
    .removeAll(where: { $0.val == "." })
    let expeditionPosition = grid.xRange
        .map { Position(x: $0, y: 0) }
        .first(where: { !grid.positions.contains($0) })!
    let goal = grid.xRange
        .map { Position(x: $0, y: grid.yRange.max()!) }
        .first(where: { !grid.positions.contains($0) })!

    let mazes = measure("creating mazes") { BlizzardMaze.createMazes(from: grid) }
    grid = Grid(data: grid.data.filter { $0.val == "#" || $0.val == "." })

    struct State: Hashable {
        let position: Position
        let minute: Int
    }
    let state = State(position: expeditionPosition, minute: 0)

    let best = maximizeIterative(
        state,
        finished: { $0.position == goal },
        score: {  400 - $0.minute }
        , maximumPotentialScore: { 400 - $0.minute - $0.position.distance(to: goal) },
        log: { print($0) }
    ) { state -> [State] in
        let destinations = mazes[state.minute % mazes.count].edges.filter { $0.from == state.position }.map(\.to)
        return destinations.map { position in
            State(
                position: position,
                minute: state.minute + 1
            )
        }
    }
    print(best)
    return best.last!.minute
}

private func part2(input: String) -> Int {
    var grid = Grid(lines: input
                        .split(whereSeparator: \.isNewline)
                        .map { line in line.map { $0 }}
    )
    .removeAll(where: { $0.val == "." })
    let expeditionPosition = grid.xRange
        .map { Position(x: $0, y: 0) }
        .first(where: { !grid.positions.contains($0) })!
    let goal = grid.xRange
        .map { Position(x: $0, y: grid.yRange.max()!) }
        .first(where: { !grid.positions.contains($0) })!

    let mazes = measure("creating mazes") { BlizzardMaze.createMazes(from: grid) }
    grid = Grid(data: grid.data.filter { $0.val == "#" || $0.val == "." })

    let maximumTime = 1000

    struct State: Hashable {
        let position: Position
        let target: Position
        let snacksForgotten: Bool
        let hasSnacks: Bool
        let minute: Int

        func minimumDuration(start: Position, goal: Position) -> Int {
            if hasSnacks {
                return minute
            } else if snacksForgotten {
                return minute + position.distance(to: target) + start.distance(to: goal)
            } else {
                return minute + position.distance(to: target) + 2 * start.distance(to: goal)
            }
        }
    }
    let state = State(
        position: expeditionPosition,
        target: goal,
        snacksForgotten: false,
        hasSnacks: false,
        minute: 0
    )

    let best = maximizeIterative(
        state,
        finished: { $0.position == $0.target && $0.hasSnacks },
        score: {  maximumTime - $0.minute }
        , maximumPotentialScore: { maximumTime - $0.minimumDuration(start: expeditionPosition, goal: goal) },
        log: { print($0) }
    ) { state -> [State] in
        let destinations = mazes[state.minute % mazes.count].edges.filter { $0.from == state.position }.map(\.to)
        return destinations.map { position in
            if position == goal, !state.snacksForgotten {
                // First time at goal
                return State(
                    position: position,
                    target: expeditionPosition,
                    snacksForgotten: true,
                    hasSnacks: false,
                    minute: state.minute + 1
                )
            } else if position == expeditionPosition, state.snacksForgotten {
                // Back at start
                return State(
                    position: position,
                    target: goal,
                    snacksForgotten: true,
                    hasSnacks: true,
                    minute: state.minute + 1
                )
            } else {
                return State(
                    position: position,
                    target: state.target,
                    snacksForgotten: state.snacksForgotten,
                    hasSnacks: state.hasSnacks,
                    minute: state.minute + 1
                )
            }
        }
    }
    print(best)
    return best.last!.minute
}

private struct BlizzardMaze {
    let blizzards: Set<Grid<Character>.Point>
    let edges: [(from: Position, to: Position)]

    static func createMazes(from grid: Grid<Character>) -> [Self] {
        let blizzards = grid.data.filter { Direction(from: $0.val) != nil }
        var uniqueConfigurations = [blizzards]
        var next = blizzards.stepBlizzards(in: grid)
        while !uniqueConfigurations.contains(next) {
            uniqueConfigurations.append(next)
            next = next.stepBlizzards(in: grid)
        }
        let emptyGridPositions = Set(grid.xRange.flatMap { x in grid.yRange.map { y in Position(x: x, y: y) }})
            .filter { !grid.data.filter { $0.val == "#" }.map(\.position).contains($0) }
        let uniqueWithEmpty = uniqueConfigurations.map { (blizzards: $0, emptyPositions: emptyGridPositions.subtracting($0.map(\.position))) }
        return zip(uniqueWithEmpty, uniqueWithEmpty.dropFirst() + uniqueWithEmpty.prefix(1))
            .map { current, next in
                Self(
                    blizzards: current.blizzards,
                    edges: current.emptyPositions.flatMap { from in
                        from.allMoves.intersection(next.emptyPositions).map { to in
                            (from: from, to: to)
                        }
                    }
                )
            }
    }
}

private extension Collection where Element == Grid<Character>.Point {
    func stepBlizzards(in grid: Grid<Character>) -> Set<Element> {
        let res = compactMap { point -> Grid<Character>.Point? in
            guard let direction = Direction(from: point.val) else {
                return nil
            }
            return grid.moveWithWrapping(point: point, in: direction)
        }
        return Set(res)
    }

    func emptyPositions(in grid: Grid<Character>) -> [Position] {
        grid.xRange.flatMap { x in grid.yRange.map { y in Position(x: x, y: y) }}
            .filter { !self.map(\.position).contains($0) }
            .filter { !grid.data.filter { $0.val == "#" }.map(\.position).contains($0) }
    }
}

private extension Position {
    var allMoves: Set<Self> {
        Set(
            Direction.allCases.map { self.move(in: $0) }
            // It's always possible to stand still
            + [self]
        )
    }
}

private extension Grid where V == Character {
    func moveWithWrapping(point: Point, in direction: Direction) -> Point {
        var destination = point.move(in: direction)
        if !xRange.shrinked(by: 1).contains(destination.x) {
            // Move backwards so it appears on other side
            destination = point.move(in: direction.inverted, step: xRange.count - 3)
        }
        if !yRange.shrinked(by: 1).contains(destination.y) {
            // Move backwards so it appears on other side
            destination = point.move(in: direction.inverted, step: yRange.count - 3)
        }
        return destination
    }

    var goal: Point { xRange
        .map { Grid<Character>.Point(x: $0, y: yRange.max()!, val: "G") }
        .first(where: { !positions.contains($0.position) })!
    }
}

private let test = """
#.#####
#.....#
#>....#
#.....#
#...v.#
#.....#
#####.#
"""

private let test2 = """
#.######
#>>.<^<#
#.<..<<#
#>v.><>#
#<^v^^>#
######.#
"""

private let input = """
#.########################################################################################################################
#<>v^<vv<v<><.^v><<.>v><<^^<v..<>.v^>^v<^><vv>.>^v>^>>v^v>><^><><<^><^>.^>^<vv>v>^>>^<^v.^<^v<.><.v><<.^v^.^<v^v<<vv><<v>#
#<>.vv^^vv<^v.^><^v<>>.<<<.^<^<>v<v<<>v>^vv..<<.^>^>>>.<>>^.^<^<<<^<>vv>.<<><^>.^>.vv^^v..v^<v^<vv.^.>v<^<^.<>^^v>^>v^<^>#
#<<>v>v>v.^<><^><>^>.v<<>.^v.v<<v<^^v>v<^^<<>^>vv<vvv>^v^.<>>^^^^<><vvv<v^>^<vv.><..><^>^<<^><^.v>>^>>>v>v>>vv^v<<.<v^<^>#
#<^.vv><^>^^>v<.>^vvv>v^v>><v>><v<><^.>v^v<v<<<>v.^>>^>v>^.>><<<v.^^^v^.v>^^vv^<<.v^<^v.v<<>><><vv.vv<^..<vv^.^<>>>.<<^^>#
#<^<v<.>vvvvvv^>>.^v>.<<v^^^><^<^^<^>v><>>><>>vv^v><^>v>>v.^>>>v^v^^^.^^>^v<.v^>^^v<vv.<.<^v>vv^v>^v>>v<^^>>^^<><^>v<v>.>#
#<vvvv<<^<v^vvv<.^<vv>.>v<v><<^v>^^<^v<^>vv^.<^vvv<^>^^vv^.v.^^..><<>^.>...^<<^>^^<^vvv>.^<>>^.v^v.^<>v^<vvvv>^.<>v>><v<>#
#>.^>.vv^<^^<v><><<>>>vv>.<><^^<>>v><<>>v^vv.>^.>v^^<^<^.>>v<<<vv<<>>.<^<><.<<^v^><>.<>^<<.^>^v<>^^>><<>vv.v<>v^^>>>>>v><#
#<.^<>.>.^>v><.^<>>>^^<^v^>^<^.>^^^v.<>vv><>v^v^v^^<^>^<<.v^>^v.<>.<^.>v><>>.<<v<^>>v>>>.^<><v<vv.<^^>^v<<<^^.<v<^>v>v^<<#
#><^>.<<<^..>>>^>.>^<vv.<.v^><>>>^<.v<^^^><>v.>.v^v<^^v><^.^.><^^<>^^v<>><^<.v>><>>>>.>^v<^v^<<^v>>.v<^<>vv<>v>vv.^<<<v.<#
#>.^^<<><v.>^^>>.^>^v>^>..>>>^v^<v^^^>v>>v>>v.^<>vv><>.<>vvvvv.vvv..><>v.vv<^v^v>^>^vv^<v<.^>>.>v^><<v>^v^>>.>^v><<^^^<v<#
#.^<>>.v<>vv<vvv^^>vv><<.^>><^.v>>^v<.v^<^v^.<vvv^^>^^>^>>>.^.>vvv>>^^^^<^^v>^>v^<v><v^<><><<^v<<<><><<v^.vv><^vv^v<<vv<>#
#<..vvv>><.v<^><v.v^^^v>^^v<<^v<>^><^v>^vvv^<^v>>^>>^<v>^<<^v^v.^vv>^><^v<^v^v>vv>^<^^^v>^^^<.>^v.v^<^>>^>^^^^^^vv<.v^^><#
#<v><<v>>^v<>>v^^v<^v<<><<^><^<<^^>.<.^v>^>>v<>^><.^<<<.>^^v^vvv><<^>>^^<^^<><v.^v<<^..v^.<v>>^v.>^<^^v<<vvv^v<^<<<<<v>^>#
#<v<<v^<^<^^v^vv<<<.>v<<><<^v^.^>><.v<^<v<^<<<<.<v^^vvv^>^^^>.><<><><<<^>v.>>>vv<.<v.><>^v^>^^^^.>v^<>.v>^.<v>v<^.v>vv<>>#
#>v<v..<^v^<<<>><>>^<^v>>v>v^>vv^v<^.vv^vv>v<<<vv.v^.>^v><<v<vv>>^<.>vvv...v<^><>>.^v>v<^^>v^v<<>v>.^>><<<><<v^<v^.^v^>v>#
#<<>^v>v>v<<<vvvv^^>v^..>..>^<>^>>><><<><v><^vv.>^v>v^v<<<vv><<.>><<<<<.<<<>^><v><vv^^v>^>>>><.^.^^>v<^<^>>.^>>^v.<>^>v>>#
#>v<<<>^^>..^>>v.v^<><^>^^<<vv<<>>^<<>v^.<^><.v>>vv^v<v<^^v..>>^^^>^v>^v^^v^>^.<^>>>v^<><v>^.<>>^^<vv>>>^><^>>.<<>>v>vv<>#
#<^^^..>>><>v>v>.>^.<.vv.vv<>v^vv<<^^>>v<^^<vv><^>><v>>>^^^><^^<.<^^>v>^^><v<vv^>vvv<^<..^>>>^v^v^^v>^^^.<.>v<^v><><>^^.>#
#>^^>^^^^.<<.v^.><v<^^.<<<.><<><>.<<<^^><.>>..<>v^^^>^v<^>>.>v><^^vvv^>>^<v>v><^<>^<>>^^v>^.v>v<<>>>^v^vv<<<^..<>^><>>^>.#
#.^<<<^^vv<.>v<.<>.>v.^..^^.>.vv.v>^>v.^.v<>v>>^^<^<^^^>>^>vvv.<^>><^>><^^>^>..^><.<v>.<^>^^v^v.>v<v^^><<>>vv^vv><v<>v^<>#
#<vvv><<>v<^<^.>..^<.<v^v^v>.^<^vv^v>v<vvv<>><>vv.vvv<^><^^>><>vv>^^^><>^<^^><^>.>v<>^.vv<v<<v^^>v<v.^^^><>^<v^<>.>.^^v^>#
#>v.^>..^>v>v>^^<^v>..>..^<.^..>>v<>.<>.<v>>>vv^<<>>>v<v^v^^vv<^vvvv<^v<^v<^^>>v>v><v><<v><v><^v<v>^>^^<>v.v<<^<.<><<<>.>#
#>>v><..^^^.<v<^^<v<><<<<<^^^<>^^v^.>vv<v><<>>^^^<v^vv^v^<>...>^.<v><<^^v^..><>vv>v^>^v>.vv<v<^.<<<v^<^v^<<v^.<.^<.>v^<><#
#>^v<..<>>v^v>v>v^v^<^<^^<..><v>^^>><<><>.^v.v<^>^<v><.^vv^.>v^>^v>^^v^>v<v^...><<<>><>>>^<vv<<^^^.<^vv^^^.v<vv<<<>>^><^<#
#>><<v<>>>vv>>^^^v^^^>^>><v<>><^vv><>>>^.v^>^>^vv<>>..^v.^^^vvvv<><^><^v>vv<<^vv>^>v..<><.>^^^v.v>vvvv>>>><<vv<>.<v^<vv>>#
########################################################################################################################.#
"""
