import Shared

private func part1(input: String) -> Int {
    let split = input.split(separator: "\n\n")
    var grid = Grid(string: String(split[0]))
    grid = Grid(data: grid.data.filter { $0.val != "." })
    let directions = split[1]
        .split(whereSeparator: \.isNewline)
        .joined(separator: "")
        .map { Direction(from: $0)! }


    let steps = directions.enumerated().reductions(grid) { grid, enm in 
        let (idx, dir) = enm
        if idx % 100 == 0 {
            print("idx", idx)
        }
        var moves: [Position] = []
        var start = grid.data.first { $0.val == "@" }!
        while true {
            moves.append(start.position)
            let destPos = start.position.move(in: dir)
            guard let dest = grid.points[destPos] else {
                break
            }
            start = dest
            if start.val == "#" {
                return grid
            }
        }
        let newPoints = grid.data.map { point in 
            if moves.contains(point.position) {
                return point.move(in: dir)
            } else {
                return point
            }
        }
        assert(Set(newPoints.map(\.position)).count == newPoints.count)
        return Grid(data: newPoints)
    }

    let final = steps.last!
    let boxes = final.data.filter { $0.val == "O" }
    let coordinates = boxes.map { $0.position.y * 100 + $0.position.x }
    return coordinates.sum
}

private func part2(input: String) -> Int {
    let split = input.split(separator: "\n\n")
    var grid = Grid(string: String(split[0]))
    grid = Grid(data: grid.data.filter { $0.val != "." }.flatMap { point -> [Grid<Character>.Point] in 
        return switch point.val {
        case "#": [
                Grid.Point(x: point.x * 2, y: point.y, val: point.val),
                Grid.Point(x: point.x * 2 + 1, y: point.y, val: point.val)
            ]
        case "O": [
                Grid.Point(x: point.x * 2, y: point.y, val: "["),
                Grid.Point(x: point.x * 2 + 1, y: point.y, val: "]")
            ]
        case "@": [
                Grid.Point(x: point.x * 2, y: point.y, val: point.val)
            ]
        default: fatalError()
        }
    })

    let directions = split[1]
        .split(whereSeparator: \.isNewline)
        .joined(separator: "")
        .map { Direction(from: $0)! }

    let steps = directions.enumerated().reductions(grid) { grid, enm in 
        let (idx, dir) = enm
        if idx % 100 == 0 {
            print("idx", idx)
        }
        var moves: Set<Position> = []
        var starts = Set([grid.data.first { $0.val == "@" }!.position])
        while true {
            moves.formUnion(starts)
            let dests = starts.compactMap { s in 
                grid.points[s.move(in: dir)]
            }
            guard !dests.isEmpty else {
                break
            }
            if dests.contains(where: { $0.val ==  "#" }) {
                return grid
            }
            starts = Set(dests.map(\.position))
            if dir == .up || dir == .down {
                for d in dests {
                    if d.val == "]" {
                        starts.insert(d.position.move(in: .left))
                    } else if d.val == "[" {
                        starts.insert(d.position.move(in: .right))
                    }
                }
            }
        }
        let newPoints =  grid.data.map { point in 
            if moves.contains(point.position) {
                return point.move(in: dir)
            } else {
                return point
            }
        }
        assert(Set(newPoints.map(\.position)).count == newPoints.count)
        return Grid(data: newPoints)
    }

    let final = steps.last!
    let boxes = final.data.filter { $0.val == "[" }
    let coordinates = boxes.map { $0.position.y * 100 + $0.position.x }
    return coordinates.sum
}

public let day15 = Solution(
    name: "day15",
    part1: part1,
    part2: part2
)
