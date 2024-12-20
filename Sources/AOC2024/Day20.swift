import Shared

private func part1(input: String) -> Int {
    let lines = input.split(whereSeparator: \.isNewline)
    let timeToSave = lines.count > 20 ? 100 : 1

    let grid = Grid(string: input)
    let original = shortest(grid: grid)
    let cheats = possibleCheats(original: original, timeAllowed: 2)
    print("toTest", cheats.count)
    return cheats.filter { $0.timeSaved >= timeToSave }.count
}

private func part2(input: String) -> Int {
    let lines = input.split(whereSeparator: \.isNewline)
    let timeToSave = lines.count > 20 ? 100 : 50

    let grid = Grid(string: input)
    let original = shortest(grid: grid)
    let cheats = possibleCheats(original: original, timeAllowed: 20)
    print("toTest", cheats.count)
    let fastCheats = cheats.filter { $0.timeSaved >= timeToSave }
    // 1067907 is too high
    return fastCheats.count
}

private struct Cheat: Hashable {
    let start: Grid<Character>.Point
    let end: Grid<Character>.Point
    let timeSaved: Int
}
private func possibleCheats(
    original: [Grid<Character>.Point],
    timeAllowed: Int
) -> [Cheat] {
    let indexed = Array(original.indexed())
    return
        indexed.flatMap { idx, start in
            indexed
                .dropFirst(idx + 1)
                .map {
                    (
                        index: $0.index,
                        element: $0.element,
                        distance: $0.element.distance(to: start)
                    )
                }
                .filter { $0.distance <= timeAllowed }
                .map {
                    Cheat(
                        start: start,
                        end: $0.element,
                        timeSaved: $0.index - idx - $0.distance
                    )
                }
        }
}

private func print(cheats: [Cheat]) {
    for (saved, group) in cheats.grouped(by: \.timeSaved).sorted(by: { $0.key < $1.key }) {
        print("There are \(group.count) cheats that save \(saved) picoseconds.")
    }
}

private func shortest(grid: Grid<Character>) -> [Grid<Character>.Point] {
    let start = grid.data.first { $0.val == "S" }!
    let end = grid.data.first { $0.val == "E" }!
    let shortest = aStar(start: start) { pos in
        pos.position == end.position
    } estimatedCostToFinish: { pos in
        pos.distance(to: end)
    } candidates: { pos in
        grid.neighbours(to: pos).values
            .filter { $0.val != "#" }
            .map { ($0, 1) }
    }  //?.dropFirst(1)
    return Array(shortest!)
}

public let day20 = Solution(
    name: "day20",
    part1: part1,
    part2: part2
)
