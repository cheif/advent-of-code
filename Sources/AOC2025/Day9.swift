import Algorithms
import Shared

private func part1(input: String) -> Int {
    let red = input.split(whereSeparator: \.isNewline).map { Position(string: $0)! }
    let rectangles = red.permutations(ofCount: 2).map { positions in
        positions.xRange.count * positions.yRange.count
    }
    // 475942047 is incorrect
    return rectangles.max() ?? 0
}

private func part2(input: String) -> Int {
    let red = input.split(whereSeparator: \.isNewline).map { Position(string: $0)! }
    let mapping = Mapping(positions: red)
    let mapped = red.map(mapping.map(_:))
    let perimeter = zip(mapped, mapped.shifted()).flatMap { lhs, rhs in
        let xRange = min(lhs.x, rhs.x)...max(lhs.x, rhs.x)
        let yRange = min(lhs.y, rhs.y)...max(lhs.y, rhs.y)
        return xRange.flatMap { x in yRange.map { y in Position(x: x, y: y) } }
    }
    let green = Set(
        mapped.xRange.flatMap { x in
            let sameX = perimeter.filter { $0.x == x }
            let yRange = sameX.map(\.y).min()!...sameX.map(\.y).max()!
            return yRange.compactMap { y -> Position? in
                let sameY = perimeter.filter { $0.y == y }
                let pos = Position(x: x, y: y)
                guard
                    sameY.contains(where: { $0.x <= pos.x })
                        && sameY.contains(where: { $0.x >= pos.x })
                else {
                    return nil
                }
                return pos
            }
        }
    )
    let rectangles = mapped.permutations(ofCount: 2).map { positions in
        let lhs = positions[0]
        let rhs = positions[1]
        let xRange = min(lhs.x, rhs.x)...max(lhs.x, rhs.x)
        let yRange = min(lhs.y, rhs.y)...max(lhs.y, rhs.y)
        let topLeft = mapping.unmap(Position(x: xRange.lowerBound, y: yRange.lowerBound))
        let bottomRight = mapping.unmap(Position(x: xRange.upperBound, y: yRange.upperBound))
        let size = (bottomRight.x - topLeft.x + 1) * (bottomRight.y - topLeft.y + 1)
        return (xRange, yRange, size: size)
    }
    .sorted { $0.size > $1.size }
    let largestInside = rectangles.first { xRange, yRange, _ in
        let perimeter =
            xRange.flatMap { x in
                [Position(x: x, y: yRange.lowerBound), Position(x: x, y: yRange.upperBound)]
            }
            + yRange.flatMap { y in
                [Position(x: xRange.lowerBound, y: y), Position(x: xRange.upperBound, y: y)]
            }
        return perimeter.allSatisfy(green.contains)
    }
    // 388115910 is too low
    // 2041141740 is too high
    // 4672641514 is too high
    return largestInside?.size ?? 0
}

private struct Mapping {
    let x: [Int: Int]
    let y: [Int: Int]
    init(positions: [Position]) {
        x = Dictionary(
            uniqueKeysWithValues: positions.map(\.x).uniqued().sorted().enumerated().map {
                ($0.offset, $0.element)
            })
        y = Dictionary(
            uniqueKeysWithValues: positions.map(\.y).uniqued().sorted().enumerated().map {
                ($0.offset, $0.element)
            })
    }

    func map(_ position: Position) -> Position {
        let x = self.x.first(where: { $0.value == position.x })!.key
        let y = self.y.first(where: { $0.value == position.y })!.key
        return Position(x: x, y: y)
    }

    func unmap(_ position: Position) -> Position {
        Position(
            x: self.x[position.x]!,
            y: self.y[position.y]!
        )
    }
}

public let day9 = Solution(
    name: "day9",
    part1: part1,
    part2: part2
)
