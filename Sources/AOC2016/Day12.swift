import Shared

private func part1(input: String) -> Int {
    var registers = [
        "a": 0,
        "b": 0,
        "c": 0,
        "d": 0,
    ]
    registers = run(input: input, registers: registers)
    return registers["a"]!
}

private func part2(input: String) -> Int {
    var registers = [
        "a": 0,
        "b": 0,
        "c": 1,
        "d": 0,
    ]
    registers = run(input: input, registers: registers)
    return registers["a"]!
}

private func run(input: String, registers: [String: Int]) -> [String: Int] {
    var registers = registers
    let instructions = input.split(whereSeparator: \.isNewline).map { $0.split(separator: " ").map { String($0) }}
    var pc = 0
    while pc < instructions.count {
        let ins = instructions[pc]
        switch ins[0] {
        case "cpy":
            let val = registers[ins[1]] ?? Int(ins[1])!
            registers[ins[2]] = val
            pc += 1
        case "inc":
            registers[ins[1]]! += 1
            pc += 1
        case "dec":
            registers[ins[1]]! -= 1
            pc += 1
        case "jnz":
            if registers[ins[1]] != 0 {
                pc += Int(ins[2])!
            } else {
                pc += 1
            }
        default:
            fatalError()
        }
    }
    return registers
}

public let day12 = Solution(
    name: "day12",
    part1: part1,
    part2: part2
)
