import Algorithms
import Shared

private func part1(input: String) -> Int {
    var grid = Grid<Character>(string: input)
    grid = Grid(data: grid.data.filter { $0.val == "@" })
    let accessible = grid.data.filter { roll in
        grid.adjacentAll(to: roll).count < 4
    }
    return accessible.count
}

private func part2(input: String) -> Int {
    var grid = Grid<Character>(string: input)
    grid = Grid(data: grid.data.filter { $0.val == "@" })

    var states = [grid]
    while true {
        let current = states.last!
        let rolls = current.data
        let accessible = rolls.filter { roll in
            current.adjacentAll(to: roll).count < 4
        }
        if accessible.isEmpty {
            break
        }
        let new = Grid(data: current.data.filter { !accessible.contains($0) })
        states.append(new)
    }

    let removed = grid.data.filter { $0.val == "@" }.filter { !states.last!.data.contains($0) }
    return removed.count
}

public let day4 = Solution(
    name: "day4",
    part1: part1,
    part2: part2
)
