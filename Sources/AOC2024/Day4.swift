import Shared

private func part1(input: String) -> Int {
    let grid = Grid(string: input)
    let starts = grid.data.filter { $0.val == "X" }
    let words = starts.map { start in
        let candidates = Direction.allCases
            .flatMap { dir -> [[Direction]] in
                [[dir], [dir, dir.rotate(.right)]]
            }
            .map { dirs in
                return [start] + (1...3).compactMap { step in
                    start.move(in: dirs, step: step)
                }
            }
            .map { points in
                points.compactMap { grid.points[$0.position] }
            }
        let valid = candidates.filter { points in
            points.map(\.val) == ["X", "M", "A", "S"]
        }
        return valid.count
    }
    return words.sum
}

private func part2(input: String) -> Int {
    let grid = Grid(string: input)
    let starts = grid.data.filter { $0.val == "A" }//.sorted(by: { $0.y < $1.y }).dropFirst().prefix(1)
    let xMases = starts.filter { start in
        let candidates = Direction.diagonals.map { diagonal in
            (-1...1)
                .map { step in start.move(in: diagonal, step: step) }
                .compactMap { grid.points[$0.position] }
        }
        let valid = candidates.filter { points in
            points.map(\.val) == ["M", "A", "S"]
        }
        return valid.count == 2
    }
    return xMases.count
}

public let day4 = Solution(
    name: "day4",
    part1: part1,
    part2: part2
)
