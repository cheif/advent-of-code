public func day24() {
//    print(part1(input: test2))
    print(part1(input: input))
//    print(part2(input: test))
    // 308 is too high
}

private func part1(input: String) -> Int {
    var grid = Grid(lines: input
                        .split(whereSeparator: \.isNewline)
                        .map { line in line.map { $0 }}
    )
    .removeAll(where: { $0.val == "." })
    let expeditionPosition = grid.xRange
        .map { Grid<Character>.Point(x: $0, y: 0, val: "E") }
        .first(where: { !grid.positions.contains($0.position) })!
    let goal = grid.xRange
        .map { Grid<Character>.Point(x: $0, y: grid.yRange.max()!, val: "G") }
        .first(where: { !grid.positions.contains($0.position) })!
    
    var state = State(
        blizzards: grid.data.filter { Direction(from: $0.val) != nil }, 
        expedition: expeditionPosition, 
        goal: goal
//        minute: 0
    )
    
    grid = Grid(data: grid.data.filter { $0.val == "#" || $0.val == "." })
    
//    print("Initial state")
//    plot(state)
    
//    var checkedStates: Set<State> = Set()
    let initialState = state
    var bestDuration: Int = 400
    var cameFrom: [State: (state: State, duration: Int)] = [:]
    var best: State?
    var statesToCheck = Set([state])
    func duration(state: State) -> Int {
        if state == initialState {
            return 0
        } else {
            return 1 + cameFrom[state]!.duration
        }
    }
    var iteration = 1
    while !statesToCheck.isEmpty {
        let toCheck = statesToCheck.min(by: { $0.minimumTimeLeft < $1.minimumTimeLeft })!
        statesToCheck.remove(toCheck)
        if toCheck.isFinished { 
            if duration(state: toCheck) < bestDuration {
                print("Found better candidate: \(duration(state: toCheck))")
                bestDuration = duration(state: toCheck)
                best = toCheck
            }
            continue
        }
        for candidate in toCheck.advance(in: grid) {
            let minutes = duration(state: toCheck)
            if let parent = cameFrom[candidate], parent.duration <= minutes {
                // Already has a better path here, don't do anything
            } else if (minutes + candidate.minimumTimeLeft) < bestDuration {
                cameFrom[candidate] = (toCheck, minutes)
                statesToCheck.insert(candidate)
            }
        }
        
        if iteration % 100 == 0 {
            print("iteration: \(iteration), checked: \(cameFrom.count), toCheck: \(statesToCheck.count), bestDuration: \(bestDuration)")
        }
        if iteration % 1000 == 0 {
            print("Best: \(best.map(duration(state:)))")
        }
        iteration += 1
//        }
    }
    
    plot(best!, in: grid)
    print(duration(state: best!))
//    let finished = checkedStates.union(statesToCheck).filter(\.isFinished).min(by: { $0.minute < $1.minute })!
//    plot(finished, in: grid)
//    print(bestDuration)
//    return finished.minute
    return 0
}

private var blizzardCache: [[Grid<Character>.Point]: [Grid<Character>.Point]] = [:]
private struct State: Hashable {
    let blizzards: [Grid<Character>.Point]
    let expedition: Grid<Character>.Point
    let goal: Grid<Character>.Point
//    let minute: Int
    
    func advance(in grid: Grid<Character>) -> [Self] {
        let newBlizzards = stepBlizzards(in: grid)
        
        let allMoves = Direction.allCases.map { expedition.move(in: $0) }
            // It's always possible to stand still
            + [expedition]
        let possibleMoves = allMoves
            .filter { 
                grid.xRange.shrinked(by: 1).contains($0.x) && 
                    !newBlizzards.map(\.position).contains($0.position) &&
                    (
                        grid.yRange.shrinked(by: 1).contains($0.y) ||
                            $0.position == goal.position ||
                            $0.position == expedition.position
                    )
            }
        return possibleMoves.map { newPosition in
            Self(blizzards: newBlizzards, expedition: newPosition, goal: goal)//, minute: minute + 1)
        }
    }
    
    var isFinished: Bool {
        expedition.position == goal.position
    }
    
    var minimumTimeLeft: Int {
        expedition.distance(to: goal)
    }
    
//    var minimumDuration: Int {
//        minute + expedition.distance(to: goal)
//    }
//    
//    var potential: Int {
//        10000 - 10 * expedition.distance(to: goal) - minute
//    }
    
    private func stepBlizzards(in grid: Grid<Character>) -> [Grid<Character>.Point] {
        if let cached = blizzardCache[blizzards] { return cached }
        let res = blizzards.compactMap { point -> Grid<Character>.Point? in 
            guard let direction = Direction(from: point.val) else {
                return nil
            }
            return grid.moveWithWrapping(point: point, in: direction)
        }
        blizzardCache[blizzards] = res
        return res
    }
}

private func plot(_ state: State, in grid: Grid<Character>) {
    let blizzards = Dictionary(grouping: state.blizzards, by: \.position)
        .map { position, values in 
            if values.count > 1 {
                return (position, "\(values.count)")
            } else {
                return (position, "\(values[0].val)")
            }
        }
    plot(grid, extra: blizzards + [(state.expedition.position, String(state.expedition.val))])
    print("")
}

private func part2(input: String) -> Int {
    return 0
}

private extension Grid where V == Character {
    func stepBlizzards() -> Self {
        let blizzards = data.compactMap { point -> (from: Point, to: Point)? in 
            guard let direction = Direction(from: point.val) else {
                return nil
            }
            return (from: point, to: self.moveWithWrapping(point: point, in: direction))
        }
        let moves: [Point: Point] = Dictionary(uniqueKeysWithValues: blizzards)
        let transformed = data.map { moves[$0] ?? $0 }
        return Self(data: transformed)
        
    }
    
    fileprivate func moveWithWrapping(point: Point, in direction: Direction) -> Point {
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
