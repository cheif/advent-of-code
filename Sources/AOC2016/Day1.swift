import Algorithms
import Shared

private func part1(input: String) -> Int {
    let finalPosition = positions(input: input).last!
    return finalPosition.distance(to: Position(x: 0, y: 0))
}

private func part2(input: String) -> Int {
    let positions = positions(input: input)
    let firstSeenTwice = positions.indexed().dropFirst().first(where: { idx, position in
        positions.prefix(upTo: idx).contains(position)
    })!.element
    return firstSeenTwice.distance(to: Position(x: 0, y: 0))
}

private func positions(input: String) -> [Position] {
    enum Ins {
        case rotateAndMove(Direction.Rotation)
        case moveForward
    }
    let instructions = input.split(separator: ", ").flatMap { direction -> [Ins] in
        let steps = Int(String(direction.dropFirst()))!
        let rotation: Direction.Rotation = switch direction.first {
        case "L": .left
        case "R": .right
        default: fatalError()
        }
        return [.rotateAndMove(rotation)] + (1..<steps).map { _ in .moveForward }
    }
    typealias Loc = (Direction, Position)
    return instructions.reductions((.up, Position(x: 0, y: 0))) { acc, instruction -> Loc in
        switch instruction {
        case .rotateAndMove(let rotation):
            let newDirection = acc.0.rotate(rotation)
            return (newDirection, acc.1.move(in: newDirection))
        case .moveForward:
            return (acc.0, acc.1.move(in: acc.0))
        }
    }.map(\.1)
}

public let day1 = Solution(
    name: "day1",
    part1: part1,
    part2: part2
)
