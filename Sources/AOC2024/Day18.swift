import Shared

private func part1(input: String) -> String {
    let lines = input.split(whereSeparator: \.isNewline)
    let bytes = lines.map { line in
        let s = line.split(separator: ",").map { Int($0)! }
        return Position(x: s[0], y: s[1])
    }

    let size = lines.count > 30 ? 70 : 6
    let start = Position(x: 0, y: 0)
    let end = Position(x: size, y: size)
    let prefix = lines.count > 30 ? 1024 : 12

    let dropped = Set(bytes.prefix(prefix))

    let shortest = aStar(start: start) { pos in
        return pos == end
    } estimatedCostToFinish: { pos in
        pos.distance(to: end)
    } candidates: { pos in
        return Direction.allCases
            .map { dir in pos.move(in: dir) }
            .filter { $0.x >= 0 && $0.x <= size && $0.y >= 0 && $0.y <= size }
            .filter { !dropped.contains($0) }
            .map { position in
                return (position, 1)
            }
    }
    // 140 is incorrect
    return String(shortest?.dropFirst().count ?? 0)
}

private func part2(input: String) -> String {
    let lines = input.split(whereSeparator: \.isNewline)
    let bytes = lines.map { line in
        let s = line.split(separator: ",").map { Int($0)! }
        return Position(x: s[0], y: s[1])
    }

    let size = lines.count > 30 ? 70 : 6
    let start = Position(x: 0, y: 0)
    let end = Position(x: size, y: size)

    let firstBlocked = lines.indices.reversed().lazy.compactMap { prefix -> Position? in
        let dropped = Set(bytes.prefix(prefix))
        let shortest = aStar(start: start) { pos in
            return pos == end
        } estimatedCostToFinish: { pos in
            pos.distance(to: end)
        } candidates: { pos in
            return Direction.allCases
                .map { dir in pos.move(in: dir) }
                .filter { $0.x >= 0 && $0.x <= size && $0.y >= 0 && $0.y <= size }
                .filter { !dropped.contains($0) }
                .map { position in
                    return (position, 1)
                }
        }
        if shortest != nil {
            return bytes[prefix]
        } else {
            return nil
        }
    }
    .lazy
    .first
    return firstBlocked.map { "\($0.x),\($0.y)" } ?? ""
}

public let day18 = Solution(
    name: "day18",
    part1: part1,
    part2: part2
)
