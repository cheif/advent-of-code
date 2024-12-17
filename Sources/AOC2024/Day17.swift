import Foundation
import Shared

private func part1(input: String) -> String {
    let (registers, program) = parse(input: input)
    let output = program.run(registers: registers)

    return output.map { String($0) }.joined(separator: ",")
}

private func part2(input: String) -> String {
    var (registers, program) = parse(input: input)

    // We need one byte per number in output
    var bytes = (0..<program.count).map { _ in 
        0b000
    }

    var validPrefixes: [[Int]] = [[]]
    for i in bytes.indices {
        validPrefixes = validPrefixes.flatMap { prefix in 
            let toTest = (0..<8).map { prefix + [$0] }

            return toTest.filter { prefix in 
                for (offset, val) in prefix.enumerated() {
                    bytes[offset] = val
                }
                registers["A"] = bytes.reversed().enumerated().map { offset, v in v << (offset*3) }.sum
                let output = program.run(registers: registers)
                return output.suffix(i) == program.suffix(i)
            }
        }
    }
    let validValueForA = validPrefixes.map { bytes in 
        bytes.reversed().enumerated().map { offset, v in v << (offset*3) }.sum
    }

    let checked = validValueForA.filter { a in
        registers["A"] = a
        return program.run(registers: registers) == program
    }

    return checked.min().map { String($0) } ?? ""
}

private typealias Program = [Int]
private func parse(input: String) -> ([String: Int], Program) {
    let split = input.split(separator: "\n\n")
    let r = split[0].split(whereSeparator: \.isNewline)
        .map { line in 
            let s = line.dropFirst(9).split(separator: ": ")
            return (String(s[0]), Int(s[1])!)
        }
    return (
        Dictionary(uniqueKeysWithValues: r),
        split[1].dropFirst(9).split(separator: ",").map { Int($0)! }
    )
}

extension Program {
    func run(registers: [String: Int]) -> [Int] {
        var registers = registers
        var pc = 0
        var output: [Int] = []
        while pc < self.count {
            let ins = self[pc]
            let literal = self[pc+1]
            let combo = switch literal {
            case 4: registers["A"]!
            case 5: registers["B"]!
            case 6: registers["C"]!
            default: literal
            }
            switch ins {
            case 0: registers["A"] = registers["A"]! >> combo
            case 1: registers["B"] = registers["B"]! ^ literal
            case 2: registers["B"] = combo % 8
            case 3: 
                if registers["A"] != 0 {
                    pc = literal
                    continue
                }
            case 4: registers["B"] = registers["B"]! ^ registers["C"]!
            case 5: output.append(combo % 8)
            case 6: registers["B"] = registers["A"]! >> combo
            case 7: registers["C"] = registers["A"]! >> combo
            default:
                fatalError()
            }
            pc += 2
        }
        return output
    }
}

public let day17 = Solution(
    name: "day17",
    part1: part1,
    part2: part2
)
