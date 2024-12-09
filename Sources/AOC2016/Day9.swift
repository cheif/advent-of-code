import Shared

private func part1(input: String) -> Int {
    var res = ""
    var offset = input.startIndex
    while offset < input.endIndex {
        let char = input[offset]
        if char == "(" {
            let end = input.suffix(from: offset).firstIndex(of: ")")!
            let marker = input[input.index(after: offset)..<end]
            let parts = marker.split(separator: "x")
            let len = Int(parts[0])!
            let reps = Int(parts[1])!
            let repStart = input.index(end, offsetBy: 1)
            let repEnd = input.index(repStart, offsetBy: len)
            let part = input[repStart..<repEnd]
            res.append((0..<reps).map { _ in part }.joined())
            offset = repEnd
        } else {
            res.append(char)
            offset = input.index(after: offset)
        }
    }

    return res.count
}

private func part2(input: String) -> Int {
    var res = 0
    var offset = input.startIndex
    while offset < input.endIndex {
        let char = input[offset]
        if char == "(" {
            let end = input.suffix(from: offset).firstIndex(of: ")")!
            let marker = input[input.index(after: offset)..<end]
            let parts = marker.split(separator: "x")
            let len = Int(parts[0])!
            let reps = Int(parts[1])!
            let repStart = input.index(end, offsetBy: 1)
            let repEnd = input.index(repStart, offsetBy: len)
            let part = input[repStart..<repEnd]
            offset = repEnd
            res += part2(input: String(part)) * reps
        } else {
            res += 1
            offset = input.index(after: offset)
        }
    }
    return res
}

public let day9 = Solution(
    name: "day9",
    part1: part1,
    part2: part2
)
