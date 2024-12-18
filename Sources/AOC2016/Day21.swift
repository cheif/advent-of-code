import Algorithms
import Shared

private func part1(input: String) -> String {
    let operations = parse(input: input)
    let start = (operations.count > 10 ? "abcdefgh" : "abcde").map { String($0) }
    let scrambled = operations.reduce(into: start) { acc, op in op(&acc) }.joined()
    return scrambled
}

private func part2(input: String) -> String {
    let operations = parse(input: input)
    let scrambled = (operations.count > 10 ? "fbgdceah" : "decab").map { String($0) }
    let start = scrambled.permutations()
        .lazy
        .first { word in
            let res = operations.reduce(into: word) { acc, op in op(&acc) }
            return res == scrambled
        }!
    return start.joined()
}

private typealias Operation = (inout [String]) -> Void
private func parse(input: String) -> [Operation] {
    let lines = input.split(whereSeparator: \.isNewline)
    return lines.map { line in
        let s = line.split(separator: " ").map { String($0) }
        let ints = s.compactMap { Int($0) }
        switch (s[0], s[1]) {
        case ("swap", "position"):
            return { word in 
                let c = word[ints[0]]
                word[ints[0]] = word[ints[1]]
                word[ints[1]] = c
            }
        case ("swap", "letter"):
            return { word in 
                let x = s[2]
                let y = s[5]
                word = word.map { l in l == x ? y : (l == y ? x : l) }
            }
        case ("rotate", "left"):
            return { word in 
                word.shift(ints[0])
            }
        case ("rotate", "right"):
            return { word in 
                let toRotate = (2*word.count - ints[0]) % word.count
                word.shift(toRotate)
            }
        case ("rotate", "based"):
            return { word in 
                let offset = word.firstIndex(of: s.last!)!
                let calculated = offset >= 4 ? (offset + 2) : (offset + 1)
                let toRotate = (2*word.count - calculated) % word.count
                word.shift(toRotate)
            }
        case ("reverse", "positions"):
            return { word in 
                let range = ints[0]...ints[1]
                word[range].reverse()
            }
        case ("move", "position"):
            return { word in 
                let l = word.remove(at: ints[0])
                word.insert(l, at: ints[1])
            }
        default:
            fatalError()
        }
    }
}

public let day21 = Solution(
    name: "day21",
    part1: part1,
    part2: part2
)
