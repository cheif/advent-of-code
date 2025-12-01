import Algorithms
import Shared

private func part1(input: String) -> Int {
    let rotations = input.split(whereSeparator: \.isNewline).map { r in
        let p = r.prefix(1)
        if p == "L" {
            return -Int(r.dropFirst())!
        } else {
            return Int(r.dropFirst())!
        }
    }
    return safeLocations(rotations: rotations).filter { $0 == 0 }.count
}

private func part2(input: String) -> Int {
    let rotations = input.split(whereSeparator: \.isNewline).flatMap { r in
        let p = r.prefix(1)
        let n = Int(r.dropFirst())!
        if p == "L" {
            return (0..<n).map { _ in -1 }
        } else {
            return (0..<n).map { _ in 1 }
        }
    }
    return safeLocations(rotations: rotations).filter { $0 == 0 }.count
}

private func safeLocations(rotations: [Int]) -> [Int] {
    rotations.reductions(50) { curr, rot in
        return (curr + rot + 100).remainderReportingOverflow(dividingBy: 100).0
    }
}

public let day1 = Solution(
    name: "day1",
    part1: part1,
    part2: part2
)
