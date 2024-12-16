import Shared

private func part1(input: String) -> Int {
    let discs = parse(input: input)
    return (0...).lazy.first { offset in
        discs.allSatisfy { disc in
            (disc.initial + disc.offset + offset) % disc.positions == 0
        }
    } ?? 0
}

private func part2(input: String) -> Int {
    var discs = parse(input: input)
    discs.append((discs.count + 1, 11, 0))
    // 4530784 too high
    return (0...).lazy.first { offset in
        discs.allSatisfy { disc in
            (disc.initial + disc.offset + offset) % disc.positions == 0
        }
    } ?? 0
}

private typealias Disc = (offset: Int, positions: Int, initial: Int)
private func parse(input: String) -> [Disc] {
    input.split(whereSeparator: \.isNewline).map { line -> Disc in
        let splits = line.dropFirst(6).dropLast().split(separator: " ").compactMap { Int($0) }
        return (splits[0], splits[1], splits[2])
    }
}

public let day15 = Solution(
    name: "day15",
    part1: part1,
    part2: part2
)
