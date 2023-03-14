public func day5() {
//    print(part1(input: input))
    print(part2(input: input))
}

private func part1(input: String) -> String {
    let (stack, moves) = parse(input: input)
    let resulting = moves.reduce(into: stack) { partialResult, move in
        for _ in 0..<move.count {
            let eln = partialResult[move.from - 1].removeFirst()
            partialResult[move.to - 1].insert(eln, at: 0)
        }
    }
    return resulting.map { String($0.first!) }.joined()
}

private func part2(input: String) -> String {
    let (stack, moves) = parse(input: input)
    let resulting = moves.reduce(into: stack) { partialResult, move in
        let eln = partialResult[move.from - 1].prefix(move.count)
        partialResult[move.from - 1].removeFirst(move.count)
        partialResult[move.to - 1].insert(contentsOf: eln, at: 0)
    }
    return resulting.map { String($0.first!) }.joined()
}

private func parse(input: String) -> ([[Character]], [Move]) {
    let splitted = input.split(separator: "\n\n")
    let stackLines = splitted[0]
        .split(whereSeparator: \.isNewline)
        .map(Array.init)
        .map { line in 
            let noStacks = (line.count + 1) / 4
            let offsets = (0..<noStacks).map { $0 * 4 + 1 }
            return offsets.map { line[$0] }
        }
        .dropLast()
    let noStacks = stackLines[0].count
    var stacks = (0..<noStacks).map { index in
        stackLines.compactMap { line in
            let eln = line[index]
            if eln != " " {
                return eln
            } else {
                return nil
            }
        }
    }
    return (stacks, parseMoves(input: String(splitted[1])))
}

typealias Move = (from: Int, to: Int, count: Int)
private func parseMoves(input: String) -> [Move] {
    return input.split(whereSeparator: \.isNewline)
        .map { line in 
            let integers = line.split(whereSeparator: \.isWhitespace).compactMap { Int($0) }
            return (
                from: integers[1],
                to: integers[2],
                count: integers[0]
            )
        }
    return []
}

private let test = """
    [D]    
[N] [C]    
[Z] [M] [P]
 1   2   3 

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2
"""

private let input = """
    [C]         [Q]         [V]    
    [D]         [D] [S]     [M] [Z]
    [G]     [P] [W] [M]     [C] [G]
    [F]     [Z] [C] [D] [P] [S] [W]
[P] [L]     [C] [V] [W] [W] [H] [L]
[G] [B] [V] [R] [L] [N] [G] [P] [F]
[R] [T] [S] [S] [S] [T] [D] [L] [P]
[N] [J] [M] [L] [P] [C] [H] [Z] [R]
 1   2   3   4   5   6   7   8   9 

move 2 from 4 to 6
move 4 from 5 to 3
move 6 from 6 to 1
move 4 from 1 to 4
move 4 from 9 to 4
move 7 from 2 to 4
move 1 from 9 to 3
move 1 from 2 to 6
move 2 from 9 to 5
move 2 from 6 to 8
move 5 from 8 to 1
move 2 from 6 to 9
move 5 from 8 to 3
move 1 from 5 to 4
move 3 from 7 to 2
move 10 from 4 to 7
move 7 from 4 to 3
move 1 from 4 to 7
move 1 from 7 to 9
move 1 from 2 to 3
move 11 from 1 to 7
move 12 from 3 to 7
move 8 from 3 to 8
move 29 from 7 to 2
move 3 from 7 to 3
move 3 from 9 to 2
move 4 from 5 to 3
move 7 from 3 to 5
move 28 from 2 to 3
move 1 from 7 to 5
move 2 from 8 to 5
move 2 from 4 to 1
move 2 from 1 to 4
move 1 from 7 to 6
move 1 from 7 to 1
move 3 from 2 to 8
move 1 from 1 to 7
move 9 from 5 to 3
move 12 from 3 to 1
move 1 from 4 to 3
move 1 from 6 to 4
move 3 from 2 to 9
move 16 from 3 to 7
move 2 from 9 to 6
move 5 from 7 to 2
move 1 from 9 to 7
move 1 from 4 to 2
move 13 from 7 to 2
move 13 from 2 to 7
move 12 from 7 to 8
move 2 from 6 to 4
move 16 from 8 to 1
move 4 from 3 to 1
move 3 from 3 to 2
move 1 from 5 to 7
move 1 from 5 to 3
move 3 from 4 to 6
move 19 from 1 to 3
move 5 from 8 to 4
move 6 from 3 to 2
move 5 from 4 to 2
move 1 from 7 to 4
move 1 from 4 to 9
move 3 from 6 to 7
move 1 from 9 to 2
move 16 from 2 to 4
move 9 from 1 to 8
move 10 from 4 to 2
move 2 from 7 to 5
move 5 from 8 to 4
move 12 from 2 to 9
move 2 from 7 to 4
move 12 from 9 to 5
move 11 from 5 to 6
move 3 from 1 to 9
move 1 from 5 to 7
move 2 from 9 to 2
move 10 from 3 to 2
move 1 from 9 to 2
move 2 from 8 to 9
move 1 from 7 to 8
move 1 from 8 to 4
move 7 from 2 to 6
move 1 from 1 to 5
move 5 from 3 to 1
move 1 from 5 to 1
move 2 from 3 to 9
move 2 from 1 to 6
move 3 from 9 to 8
move 14 from 6 to 1
move 1 from 3 to 5
move 5 from 4 to 6
move 1 from 9 to 6
move 7 from 6 to 9
move 1 from 6 to 2
move 8 from 1 to 4
move 7 from 1 to 7
move 10 from 2 to 1
move 4 from 7 to 6
move 10 from 4 to 6
move 5 from 8 to 2
move 1 from 5 to 9
move 2 from 2 to 6
move 2 from 4 to 7
move 1 from 2 to 7
move 5 from 9 to 2
move 1 from 2 to 9
move 14 from 6 to 8
move 2 from 8 to 4
move 1 from 2 to 6
move 4 from 9 to 3
move 2 from 6 to 8
move 5 from 4 to 5
move 5 from 8 to 3
move 1 from 2 to 4
move 3 from 7 to 1
move 2 from 2 to 7
move 1 from 4 to 7
move 1 from 4 to 5
move 1 from 2 to 8
move 1 from 4 to 9
move 8 from 8 to 2
move 3 from 1 to 5
move 7 from 2 to 9
move 8 from 1 to 6
move 6 from 7 to 2
move 2 from 2 to 8
move 5 from 1 to 8
move 3 from 6 to 8
move 4 from 3 to 6
move 3 from 6 to 2
move 8 from 9 to 2
move 11 from 5 to 7
move 12 from 2 to 6
move 2 from 3 to 7
move 12 from 7 to 2
move 10 from 6 to 9
move 1 from 7 to 1
move 12 from 8 to 7
move 2 from 3 to 2
move 8 from 9 to 7
move 6 from 2 to 5
move 1 from 1 to 6
move 3 from 2 to 6
move 1 from 3 to 7
move 5 from 5 to 3
move 10 from 7 to 2
move 2 from 3 to 7
move 8 from 7 to 6
move 20 from 2 to 8
move 5 from 8 to 1
move 5 from 8 to 6
move 1 from 5 to 7
move 1 from 1 to 4
move 4 from 1 to 2
move 1 from 9 to 6
move 3 from 3 to 1
move 4 from 7 to 5
move 1 from 9 to 8
move 11 from 8 to 7
move 1 from 4 to 9
move 2 from 7 to 5
move 31 from 6 to 9
move 4 from 2 to 3
move 6 from 5 to 1
move 4 from 1 to 2
move 7 from 7 to 8
move 1 from 7 to 6
move 1 from 1 to 7
move 24 from 9 to 4
move 2 from 7 to 8
move 2 from 9 to 2
move 2 from 7 to 5
move 2 from 5 to 9
move 3 from 4 to 1
move 20 from 4 to 2
move 1 from 6 to 1
move 16 from 2 to 1
move 4 from 3 to 1
move 1 from 4 to 8
move 5 from 8 to 5
move 5 from 8 to 1
move 1 from 5 to 2
move 3 from 5 to 6
move 33 from 1 to 6
move 6 from 9 to 4
move 15 from 6 to 7
move 6 from 4 to 3
move 1 from 5 to 3
move 7 from 3 to 9
move 11 from 7 to 5
move 10 from 5 to 8
move 2 from 7 to 3
move 5 from 8 to 9
move 1 from 7 to 5
move 1 from 5 to 8
move 1 from 5 to 7
move 2 from 3 to 8
move 2 from 7 to 5
move 2 from 8 to 7
move 1 from 5 to 9
move 1 from 7 to 6
move 3 from 8 to 6
move 22 from 6 to 9
move 1 from 7 to 6
move 27 from 9 to 4
move 18 from 4 to 8
move 5 from 4 to 1
move 1 from 5 to 1
move 3 from 6 to 3
move 2 from 3 to 5
move 2 from 5 to 2
move 1 from 2 to 6
move 1 from 6 to 3
move 9 from 8 to 6
move 3 from 9 to 8
move 9 from 6 to 5
move 1 from 6 to 9
move 15 from 8 to 5
move 1 from 3 to 4
move 6 from 1 to 8
move 1 from 3 to 7
move 8 from 5 to 8
move 2 from 5 to 6
move 3 from 4 to 6
move 1 from 7 to 6
move 2 from 5 to 3
move 5 from 5 to 1
move 2 from 3 to 7
move 1 from 8 to 1
move 10 from 2 to 9
move 5 from 6 to 3
move 7 from 8 to 5
move 4 from 3 to 5
move 1 from 2 to 1
move 2 from 7 to 6
move 5 from 1 to 5
move 1 from 3 to 7
move 1 from 7 to 6
move 3 from 8 to 5
move 4 from 6 to 4
move 1 from 2 to 9
move 5 from 4 to 6
move 21 from 5 to 3
move 2 from 8 to 4
move 3 from 4 to 1
move 1 from 8 to 4
move 18 from 3 to 5
move 2 from 3 to 6
move 2 from 6 to 9
move 2 from 6 to 2
move 1 from 2 to 9
move 19 from 9 to 4
move 3 from 6 to 3
move 2 from 9 to 4
move 1 from 1 to 2
move 1 from 3 to 7
move 16 from 5 to 2
move 4 from 1 to 9
move 3 from 3 to 4
move 4 from 9 to 8
move 3 from 5 to 1
move 22 from 4 to 5
move 1 from 7 to 2
move 22 from 5 to 9
move 2 from 5 to 2
move 2 from 4 to 6
move 10 from 9 to 5
move 1 from 8 to 3
move 13 from 9 to 2
move 1 from 6 to 3
move 19 from 2 to 7
move 2 from 7 to 4
move 1 from 8 to 4
move 1 from 8 to 2
move 11 from 5 to 7
move 3 from 1 to 7
move 8 from 7 to 8
move 1 from 3 to 5
move 1 from 8 to 3
move 1 from 5 to 3
move 6 from 2 to 3
move 1 from 8 to 7
move 1 from 6 to 1
move 1 from 1 to 8
move 4 from 8 to 1
move 1 from 4 to 6
move 8 from 3 to 9
move 2 from 2 to 3
move 3 from 8 to 5
move 1 from 8 to 2
move 4 from 2 to 7
move 5 from 9 to 7
move 1 from 6 to 3
move 4 from 2 to 4
move 23 from 7 to 5
move 4 from 1 to 2
move 3 from 9 to 6
move 2 from 4 to 8
move 2 from 8 to 3
move 2 from 6 to 1
move 1 from 6 to 8
move 8 from 5 to 3
move 5 from 2 to 6
move 5 from 6 to 3
move 1 from 8 to 3
move 4 from 4 to 7
move 15 from 5 to 2
move 1 from 1 to 9
move 2 from 5 to 1
move 4 from 3 to 7
move 1 from 4 to 9
move 4 from 7 to 1
move 2 from 5 to 6
move 7 from 1 to 2
move 6 from 2 to 3
move 16 from 2 to 5
move 1 from 6 to 3
move 1 from 6 to 3
move 9 from 7 to 4
move 6 from 4 to 6
move 1 from 9 to 8
move 23 from 3 to 9
move 1 from 3 to 4
move 3 from 4 to 5
move 9 from 5 to 2
move 6 from 9 to 7
move 7 from 7 to 5
move 5 from 5 to 3
move 1 from 4 to 6
move 3 from 3 to 8
move 6 from 2 to 1
move 3 from 5 to 6
move 4 from 7 to 1
move 2 from 3 to 9
move 5 from 6 to 8
move 19 from 9 to 6
move 1 from 9 to 2
move 9 from 5 to 9
move 4 from 8 to 3
move 5 from 6 to 1
move 4 from 6 to 1
move 2 from 3 to 8
move 17 from 1 to 7
move 2 from 1 to 2
move 6 from 6 to 9
move 4 from 8 to 5
move 3 from 8 to 2
move 3 from 5 to 6
move 4 from 6 to 8
move 2 from 6 to 9
move 4 from 8 to 7
move 9 from 9 to 5
move 5 from 9 to 4
move 7 from 2 to 8
move 1 from 2 to 1
move 3 from 6 to 5
move 6 from 8 to 5
move 1 from 3 to 4
move 1 from 3 to 1
move 12 from 7 to 2
move 5 from 2 to 7
move 8 from 7 to 5
move 1 from 9 to 3
move 5 from 2 to 8
move 3 from 6 to 3
move 2 from 2 to 3
move 1 from 2 to 4
move 2 from 3 to 4
move 1 from 1 to 6
move 14 from 5 to 6
move 1 from 8 to 6
move 3 from 3 to 7
move 4 from 7 to 1
move 9 from 4 to 3
move 3 from 1 to 4
move 1 from 1 to 2
move 1 from 8 to 4
move 8 from 3 to 1
move 1 from 3 to 2
move 5 from 7 to 6
move 3 from 1 to 6
move 2 from 2 to 8
move 13 from 5 to 3
move 5 from 1 to 3
move 3 from 4 to 5
move 1 from 9 to 2
move 4 from 3 to 9
move 1 from 1 to 7
move 2 from 5 to 8
move 1 from 7 to 5
move 2 from 5 to 4
move 1 from 2 to 6
move 1 from 4 to 5
move 7 from 3 to 6
move 31 from 6 to 1
move 25 from 1 to 7
move 2 from 3 to 2
move 13 from 7 to 9
move 1 from 1 to 6
move 1 from 4 to 1
move 2 from 2 to 9
move 1 from 4 to 6
move 3 from 7 to 1
move 7 from 8 to 3
move 1 from 8 to 2
move 1 from 2 to 8
move 4 from 3 to 4
move 1 from 8 to 7
move 3 from 6 to 9
move 5 from 7 to 6
move 1 from 4 to 7
move 5 from 7 to 9
move 5 from 3 to 6
move 3 from 4 to 7
move 1 from 5 to 4
move 4 from 7 to 9
move 32 from 9 to 1
move 1 from 6 to 5
move 1 from 5 to 9
move 4 from 3 to 8
move 5 from 1 to 4
move 4 from 4 to 9
move 6 from 1 to 7
move 4 from 9 to 8
move 4 from 7 to 8
move 1 from 7 to 1
move 1 from 7 to 6
move 7 from 6 to 3
move 1 from 9 to 5
move 2 from 4 to 7
move 25 from 1 to 6
move 1 from 7 to 1
move 1 from 3 to 4
move 18 from 6 to 8
move 1 from 5 to 1
move 3 from 1 to 6
move 21 from 8 to 3
move 1 from 8 to 4
move 2 from 4 to 2
move 1 from 8 to 1
move 1 from 7 to 6
move 5 from 6 to 3
move 30 from 3 to 1
move 4 from 8 to 6
move 1 from 2 to 9
move 1 from 8 to 5
move 9 from 6 to 5
move 2 from 8 to 7
move 3 from 5 to 9
move 2 from 3 to 4
move 1 from 2 to 1
move 1 from 5 to 8
move 1 from 8 to 3
move 2 from 4 to 6
move 1 from 3 to 1
move 1 from 5 to 6
move 5 from 5 to 7
move 4 from 6 to 8
move 3 from 8 to 2
move 1 from 1 to 5
move 1 from 8 to 7
move 4 from 9 to 6
move 1 from 5 to 1
move 4 from 6 to 8
move 6 from 7 to 3
move 4 from 3 to 9
move 2 from 2 to 7
move 1 from 3 to 5
move 3 from 7 to 6
move 2 from 9 to 8
move 1 from 2 to 4
move 1 from 3 to 4
move 5 from 8 to 4
move 1 from 9 to 2
move 1 from 7 to 5
move 3 from 4 to 5
move 1 from 9 to 1
move 1 from 2 to 7
move 1 from 7 to 1
move 5 from 5 to 4
move 4 from 1 to 4
move 19 from 1 to 9
move 6 from 6 to 2
move 12 from 9 to 1
move 1 from 8 to 6
move 1 from 9 to 4
move 4 from 4 to 8
move 1 from 6 to 5
move 1 from 5 to 3
move 2 from 8 to 9
move 5 from 4 to 6
move 5 from 9 to 4
move 1 from 4 to 3
move 2 from 2 to 9
move 1 from 6 to 5
move 1 from 6 to 9
move 7 from 1 to 5
move 1 from 3 to 1
move 2 from 8 to 3
move 1 from 5 to 7
move 2 from 9 to 8
"""
