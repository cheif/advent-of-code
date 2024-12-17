import Shared

private func part1(input: String) -> Int {
    let noElves = Int(input)!
    var elves = (0..<noElves).map { idx in idx + 1 }
    while elves.count > 1 {
        let takers = elves.indices.filter { $0 % 2 == 0 }
        let toRemove = takers.map { ($0 + 1) % elves.count }.sorted()
        let ranges = RangeSet(toRemove, within: elves)
        elves.removeSubranges(ranges)
    }
    return elves[0]
}

private func part2(input: String) -> Int {
    let noElves = Int(input)!
    let elves = (0..<noElves).map { idx in idx + 1 }
    return p2Fast(elves: elves, visualize: noElves < 20)
}

private func p2Fast(elves: [Int], visualize: Bool) -> Int {
    var elves = elves
    while elves.count > 1 {
        let isEven = elves.count % 2 == 0
        let toRemove = elves.indices.dropFirst(elves.count / 2)
            .enumerated()
            .filter { ($0.offset + (isEven ? 1 : -1)) % 3 != 0 }
            .map(\.element)

        if visualize {
            print(elves)
            print("removing", toRemove.map { elves[$0] })
        }

        let ranges = RangeSet(toRemove, within: elves)
        elves.removeSubranges(ranges)
        elves.shift(toRemove.count)
    }
    return elves[0]
}

private func p2Slow(elves: [Int], visualize: Bool) -> Int {
    var elves = elves
    var pos = 0
    while elves.count > 1 {
        let toRemove = (elves.count / 2 + pos) % elves.count

        if visualize {
            print(repeatElement(" ", count: 1 + pos * 3) + "↓ here")
            print(elves)
            print(repeatElement(" ", count: 1 + toRemove * 3) + "^ removing")
            print()
        }

        elves.remove(at: toRemove)
        if toRemove > pos {
            pos = pos + 1
        }
        if !elves.indices.contains(pos) {
            pos = 0
        }
    }
    return elves[0]
}

public let day19 = Solution(
    name: "day19",
    part1: part1,
    part2: part2
)
