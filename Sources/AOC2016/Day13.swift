import Shared

private func part1(input: String) -> Int {
    let k = Int(input)!
    let start = Position(x: 1, y: 1)
    let target = k > 100 ? Position(x: 31, y: 39) : Position(x: 7, y: 4)
    let path: [Position]? = aStar(start: start) { pos in
        pos == target
    } estimatedCostToFinish: { pos in
        pos.distance(to: target)
    } candidates: { pos in
            Direction.allCases
                .map { pos.move(in: $0) }
                .filter { $0.x >= 0 && $0.y >= 0 }
                .filter { !hasWall(pos: $0, k: k) }
                .map { ($0, 1) }
    }
    return path!.dropFirst().count
}

private func part2(input: String) -> Int {
    let k = Int(input)!
    let start = Position(x: 1, y: 1)

    struct State: Hashable {
        let pos: Position
        let steps: Int
    }

    let states = exhaustiveSearch(initial: [State(pos: start, steps: 0)]) { state in
        if state.steps < 50 {
            return Direction.allCases
                .map { state.pos.move(in: $0) }
                .filter { $0.x >= 0 && $0.y >= 0 }
                .filter { !hasWall(pos: $0, k: k) }
                .map { State(pos: $0, steps: state.steps + 1) }
        } else {
            return []
        }
    }
    let unique = Set(states.map(\.pos))
    return unique.count
}

private func hasWall(pos: Position, k: Int) -> Bool {
    let x = pos.x
    let y = pos.y
    let sum = x*x + 3*x + 2*x*y + y + y*y + k
    let bin = String(sum, radix: 2)
    let ones = bin.map { $0 }.filter { $0 == "1" }.count
    return ones % 2 != 0
}

public let day13 = Solution(
    name: "day13",
    part1: part1,
    part2: part2
)
