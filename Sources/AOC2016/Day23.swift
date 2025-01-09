import Algorithms
import Shared

private func part1(input: String) -> Int {
    var registers = [
        "a": 7,
        "b": 0,
        "c": 0,
        "d": 0,
    ]
    let computer = Assembunny(input: input)
    registers = computer.run(registers: registers)
    return registers["a"]!
}

private func part2(input: String) -> Int {
    var registers = [
        "a": 12,
        "b": 0,
        "c": 0,
        "d": 0,
    ]
    let computer = Assembunny(input: input)
    registers = computer.run(registers: registers)
    return registers["a"]!
}

public let day23 = Solution(
    name: "day23",
    part1: part1,
    part2: part2
)
