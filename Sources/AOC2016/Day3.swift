import Shared

private func part1(input: String) -> Int {
    let triangles: [[Int]] = input.split(whereSeparator: \.isNewline).map { line in
        line.split(whereSeparator: \.isWhitespace).map { Int(String($0))! }
    }
    return triangles.filter(isValid(triangle:)).count
}

private func part2(input: String) -> Int {
    let triangles: [[Int]] = input.split(whereSeparator: \.isNewline).map { line in
        line.split(whereSeparator: \.isWhitespace).map { Int(String($0))! }
    }
        .chunks(ofCount: 3)
        .map { Array($0) }
        .flatMap { chunk -> [[Int]] in
            (0..<3).map { offset in
                [chunk[0][offset], chunk[1][offset], chunk[2][offset]]
            }
        }
    return triangles.filter(isValid(triangle:)).count
}

private func isValid(triangle: [Int]) -> Bool {
    let sorted = triangle.sorted()
    return sorted.dropLast().sum > sorted.last!
}

public let day3 = Solution(
    name: "day3",
    part1: part1,
    part2: part2
)
