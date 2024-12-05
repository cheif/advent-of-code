import Foundation
import Shared

private func part1(input: String) -> String {
    let grid = Grid(string: """
123
456
789
""")
    return solve(input: input, grid: grid, start: Position(x: 1, y: 1))
}

private func part2(input: String) -> String {
    let grid = Grid(string: """
  1
 234
56789
 ABC
  D
""")
    return solve(input: input, grid: grid, start: Position(x: 0, y: 2))
}

private func solve(input: String, grid: Grid<Character>, start: Position) -> String {
    let instructions: [[Direction]] = input.split(whereSeparator: \.isNewline).map { line in
        line.map { Direction(letter: $0)! }
    }
    let positions = instructions.reductions(start) { pos, moves in
        moves.reduce(pos) { pos, dir in
            let new = pos.move(in: dir)
            if let point = grid.points[new],
               point.val != " " {
                return new
            } else {
                return pos
            }
        }
    }.dropFirst()
    let numbers = positions.map { grid.points[$0]!.val }
    return String(numbers)

}

public let day2 = Solution(
    name: "day2",
    part1: part1,
    part2: part2
)
