import Shared

let grid = Grid(string: """
#########
#S| | | #
#-#-#-#-#
# | | | #
#-#-#-#-#
# | | | #
#-#-#-#-#
# | | |  
####### V
""")

private func part1(input: String) -> String {
    let start = grid.data.first { $0.val == "S" }!.position
    let end = Position(x: 7, y: 7)
    let shortest = aStar(start: State(position: start, path: [])) { state in
        state.position == end
    } estimatedCostToFinish: { state in
            state.position.distance(to: end)
        } candidates: { state in
            let toHash = input + state.path.map(\.letter).joined()
            let hash = md5(string: toHash)
            return Direction.allCases
                .filter { $0.isOpen(hash: hash.map { $0 }) }
                .filter { grid.points[state.position.move(in: $0)]!.val != "#" }
                .map { dir in 
                    (State(
                        position: state.position.move(in: dir, step: 2),
                        path: state.path + [dir]
                    ), 2)
                }
    }!
    // RDLRRDURDUDD is incorrect
    return shortest.last?.path.map(\.letter).joined() ?? ""
}

private func part2(input: String) -> String {
    let start = grid.data.first { $0.val == "S" }!.position
    let end = Position(x: 7, y: 7)
    let allPaths = exhaustiveSearch(initial: [State(position: start, path: [])]) { state in
        guard state.position != end else {
            return []
        }
        let toHash = input + state.path.map(\.letter).joined()
        let hash = md5(string: toHash)
        return Direction.allCases
            .filter { $0.isOpen(hash: hash.map { $0 }) }
            .filter { grid.points[state.position.move(in: $0)]!.val != "#" }
            .map { dir in 
                State(
                    position: state.position.move(in: dir, step: 2),
                    path: state.path + [dir]
                )
            }
    }
    let endingAtEnd = allPaths.filter { $0.position == end }
    let longest = endingAtEnd.max(by: { $0.path.count < $1.path.count})!
    return String(longest.path.count)
}

private struct State: Hashable {
    let position: Position
    let path: [Direction]
}

private extension Direction {
    var letter: String {
        return switch self {
        case .up: "U"
        case .down: "D"
        case .left: "L"
        case .right: "R"
        }
    }

    func isOpen(hash: [Character]) -> Bool {
        let v = switch self {
        case .up: hash[0]
        case .down: hash[1]
        case .left: hash[2]
        case .right: hash[3]
        }
        return v > "a"
    }
}

public let day17 = Solution(
    name: "day17",
    part1: part1,
    part2: part2
)
