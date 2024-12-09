import Shared

private func part1(input: String) -> Int {
    let iterations = iterate(input: input)
    return iterations.last!.data.filter { $0.val == "#" }.count
}

private func part2(input: String) -> Int {
    let iterations = iterate(input: input)
    plot(iterations.last!)
    return 0
}

private func iterate(input: String) -> [Grid<Character>] {
    let gridSize = input.split(whereSeparator: \.isNewline).count > 10 ? (50, 6) : (7, 3)
    let instructions = Ins.parse(input: input)
    let grid = Grid<Character>(data: (0..<gridSize.0).flatMap { x in
        (0..<gridSize.1).map { y in
            Grid<Character>.Point(x: x, y: y, val: ".")
        }
    })
    return instructions.reductions(grid) { grid, instruction in
        switch instruction {
        case .rect(let width, let height):
            return Grid(data: grid.data.map { point in
                if point.x < width && point.y < height {
                    return Grid.Point(x: point.x, y: point.y, val: "#")
                } else {
                    return point
                }
            })
        case .shiftColumn(let id, let offset):
            return Grid(data: grid.data.map { point in
                if point.x == id {
                    return Grid.Point(x: point.x, y: (point.y + offset) % gridSize.1, val: point.val)
                } else {
                    return point
                }
            })
        case .shiftRow(let id, let offset):
            return Grid(data: grid.data.map { point in
                if point.y == id {
                    return Grid.Point(x: (point.x + offset) % gridSize.0, y: point.y, val: point.val)
                } else {
                    return point
                }
            })
        }
    }
}

private enum Ins {
    case rect(Int, Int)
    case shiftColumn(Int, Int)
    case shiftRow(Int, Int)

    static func parse(input: String) -> [Self] {
        input.split(whereSeparator: \.isNewline).map { line in
            if line.contains("rect") {
                let split = line.split(separator: "x")
                return .rect(Int(split[0].dropFirst(5))!, Int(split[1])!)
            } else {
                let split = line.split(separator: " by ")
                let id = Int(split[0].split(separator: "=")[1])!
                let offset = Int(split[1])!
                if line.contains("row") {
                    return .shiftRow(id, offset)
                } else {
                    return .shiftColumn(id, offset)
                }
            }
        }
    }
}

public let day8 = Solution(
    name: "day8",
    part1: part1,
    part2: part2
)

