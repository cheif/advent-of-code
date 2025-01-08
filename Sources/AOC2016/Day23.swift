import Algorithms
import Shared

private func part1(input: String) -> Int {
    var registers = [
        "a": 7,
        "b": 0,
        "c": 0,
        "d": 0,
    ]
    registers = run(input: input, registers: registers)
    return registers["a"]!
}

private func part2(input: String) -> Int {
    var registers = [
        "a": 12,
        "b": 0,
        "c": 0,
        "d": 0,
    ]
    // Manually re-wrote input to support add/mul
    registers = run(input: input, registers: registers)
    return registers["a"]!
}

private func run(input: String, registers: [String: Int]) -> [String: Int] {
    var registers = registers
    var instructions = input.split(whereSeparator: \.isNewline).map {
        $0.split(separator: " ").map { String($0) }
    }
    var pc = 0
    while pc < instructions.count {
        let ins = instructions[pc]
        switch ins[0] {
        case "cpy":
            if registers[ins[2]] != nil {
                let val = registers[ins[1]] ?? Int(ins[1])!
                registers[ins[2]] = val
            }
            pc += 1
        case "inc":
            if registers[ins[1]] != nil {
                registers[ins[1]]! += 1
            }
            pc += 1
        case "dec":
            if registers[ins[1]] != nil {
                registers[ins[1]]! -= 1
            }
            pc += 1
        case "jnz":
            if registers[ins[1]] != 0 {
                let offset = Int(ins[2]) ?? registers[ins[2]]!
                pc += offset
            } else {
                pc += 1
            }
        case "tgl":
            let offset = pc + registers[ins[1]]!
            if instructions.indices.contains(offset) {
                let toToggle = instructions[offset]
                let new: String
                if toToggle.count == 2 {
                    new = toToggle[0] == "inc" ? "dec" : "inc"
                } else {
                    new = toToggle[0] == "jnz" ? "cpy" : "jnz"
                }
                instructions[offset][0] = new
            }
            pc += 1
        case "add":
            registers[ins[1]]! += registers[ins[2]]!
            pc += 1
        case "mul":
            registers[ins[1]]! *= registers[ins[2]]!
            pc += 1
        default:
            fatalError()
        }

    }
    return registers
}

public let day23 = Solution(
    name: "day23",
    part1: part1,
    part2: part2
)
