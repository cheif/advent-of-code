import Algorithms
import Shared

private func part1(input: String) -> Int {
    let map = Grid(string: input)
    let start = Pos(position: map.data.first(where: { $0.val == "^"})!.position, direction: .up)
    let res = move(in: map, visited: [start])

    guard case .outside(let visited) = res else {
        return 0
    }

    let unique = Set(visited.map(\.position))
    return unique.count
}

private func part2(input: String) -> Int {
    let map = Grid(string: input)
    let start = Pos(position: map.data.first(where: { $0.val == "^"})!.position, direction: .up)
    let res = move(in: map, visited: [start])

    guard case .outside(let visited) = res else {
        return 0
    }

    let mightLoop: [(Position, [Pos])] = visited.enumerated().dropFirst()
        .compactMap { offset, pos -> (Position, [Pos])? in
            let before = visited.prefix(upTo: offset)
            let next = pos.position.move(in: pos.direction)
            return (next, Array(before))
        }
        .uniqued(on: \.0)

    let looping = mightLoop.enumerated().filter { offset, attr in
        let (obstacle, visited) = attr
        let candidate = Grid(data: map.data.map {
            $0.position == obstacle ? .init(x: $0.x, y: $0.y, val: "#") : $0
        })
        return containsLoop(map: candidate, visited: visited)
    }

    // 565 is too low
    // 4452 is too high
    // 814 is too low
    // 1323 is incorrect
    // 796 is incorrect
    // 830 is incorrect
    // 819 is incorrect
    // 1430 is incorrect
    return looping.count
}

private struct Pos: Hashable {
    let position: Position
    let direction: Direction
}

private func containsLoop(map: Grid<Character>, visited: [Pos]) -> Bool {
    let res = move(in: map, visited: visited)
    switch res {
    case .looped:
        return true
    case .outside:
        return false
    }
}

private enum Res {
    case looped([Pos])
    case outside([Pos])
}
private func move(in map: Grid<Character>, visited: [Pos]) -> Res {
    var visited: [Pos] = visited
    var set = Set(visited)
    while true {
        let current = visited.last!
        let forward = current.position.move(in: current.direction)
        let new: Pos
        if map.points[forward]?.val != "#" {
            new = .init(position: forward, direction: current.direction)
        } else {
            let newDirection = current.direction.rotate(.right)
            new = .init(position: current.position, direction: newDirection)
        }
        if !map.positions.contains(new.position) {
            return .outside(visited)
        } else if set.contains(new) {
            return .looped(visited)
        } else {
            visited.append(new)
            set.insert(new)
        }
    }
}

// [Position(x: 7, y: 7), Position(x: 3, y: 6), Position(x: 3, y: 8), Position(x: 6, y: 7), Position(x: 7, y: 9), Position(x: 1, y: 8)]
public let day6 = Solution(
    name: "day6",
    part1: part1,
    part2: part2
)

