import Shared

private func part1(input: String) -> Int {
    let split = input.split(separator: "\n\n").map { String($0) }
    let locksAndKeys = split.map { s in 
        Grid(data: Grid(string: s).data.filter { $0.val == "#" })
    }
    let grouped = locksAndKeys.grouped { $0.points[Position(x: 0, y: 0)]?.val ?? "." }
    let locks = grouped["#"]!
    let keys = grouped["."]!
    let hasOverlap = locks.flatMap { lock in 
        keys.map { key in 
            lock.positions.intersection(key.positions).count > 0
        }
    }
    return hasOverlap.filter { $0 == false }.count
}

private func part2(input: String) -> Int {
    return 0
}

public let day25 = Solution(
    name: "day25",
    part1: part1,
    part2: part2
)
