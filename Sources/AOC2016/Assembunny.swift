struct Assembunny {
    let instructions: [[String]]
    init(input: String) {
        let parsed = input.split(whereSeparator: \.isNewline).map {
            $0.split(separator: " ").map { String($0) }
        }
        let withAdds = insertAddWhereApplicable(instructions: parsed)
        let withSubs = insertSubwhereApplicable(instructions: withAdds)
        instructions = insertMulWhereApplicable(instructions: withSubs)
    }

    func run(registers: [String: Int], output: (Int) -> Bool = { _ in false }) -> [String: Int] {
        var registers = registers
        var instructions = self.instructions
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
                    if offset == 0 {
                        pc += 1
                    } else {
                        pc += offset
                    }
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
            case "nop":
                pc += 1
            case "add":
                registers[ins[1]]! += registers[ins[2]] ?? Int(ins[2])!
                pc += 1
            case "sub":
                registers[ins[1]]! -= registers[ins[2]] ?? Int(ins[2])!
                pc += 1
            case "mul":
                registers[ins[1]]! *= registers[ins[2]] ?? Int(ins[2])!
                pc += 1
            case "out":
                let value = registers[ins[1]] ?? Int(ins[1])!
                let halt = output(value)
                if halt {
                    return registers
                }
                pc += 1
            default:
                fatalError()
            }
        }
        return registers
    }
}

private func insertAddWhereApplicable(instructions: [[String]]) -> [[String]] {
    // If we have this pattern, with random registers, we're actually seeing an "add a b"
    // cpy b c
    // inc a
    // dec c
    // jnz c -2
    var instructions = instructions
    for off in instructions.indices {
        let ins = instructions[off]

        // Check match backward
        if ins[0] == "jnz" && Int(ins[2]) == -2,
            instructions[off - 1] == ["dec", ins[1]],
            instructions[off - 2][0] == "inc",
            instructions[off - 3][0] == "cpy" && instructions[off - 3][2] == ins[1]
        {
            // We've got a match, replace by add, and insert nop:s
            let target = instructions[off - 2][1]
            let source = instructions[off - 3][1]
            instructions[off] = ["add", target, source]
            instructions[off - 1] = ["nop"]
            instructions[off - 2] = ["nop"]
            instructions[off - 3] = ["nop"]
        }
    }

    return instructions
}

private func insertSubwhereApplicable(instructions: [[String]]) -> [[String]] {
    // If we have this pattern, with random registers, we're actually seeing an "sub b x"
    // cpy x c
    // jnz b 2
    // ---
    // dec b
    // dec c
    // jnz c -4
    return instructions
    var instructions = instructions
    for off in instructions.indices {
        let ins = instructions[off]

        // Check match backward
        if ins[0] == "jnz" && Int(ins[2]) == -4,
            instructions[off - 1] == ["dec", ins[1]],
            instructions[off - 2][0] == "dec",
            instructions[off - 5][0] == "cpy" && instructions[off - 5][2] == ins[1]
        {
            // We've got a match, replace by sub, and insert nop:s
            let target = instructions[off - 2][1]
            let source = instructions[off - 5][1]
            instructions[off] = ["nop"]
            instructions[off - 1] = ["nop"]
            instructions[off - 2] = ["nop"]
            instructions[off - 5] = ["sub", target, source]
        }
    }

    return instructions

}

private func insertMulWhereApplicable(instructions: [[String]]) -> [[String]] {
    // If we have this pattern, with random registers, we're actually seeing an "mul a b"
    // cpy a d
    // cpy 0 a
    // nop
    // nop
    // nop
    // add a b
    // dec d
    // jnz d -5
    var instructions = instructions
    for off in instructions.indices {
        let ins = instructions[off]

        // Check match backward
        if ins[0] == "jnz" && Int(ins[2]) == -5,
            instructions[off - 1] == ["dec", ins[1]],
            instructions[off - 2][0] == "add"
        {
            if instructions[off - 6][0] == "cpy" && instructions[off - 6][1] == "0",
                instructions[off - 7][0] == "cpy" && instructions[off - 7][2] == ins[1]
            {
                // We've got a register multiply, replace by mul, and insert nop:s
                let target = instructions[off - 2][1]
                let source = instructions[off - 2][2]
                instructions[off] = ["mul", target, source]
                instructions[off - 1] = ["nop"]
                instructions[off - 2] = ["nop"]
                instructions[off - 3] = ["nop"]
                instructions[off - 4] = ["nop"]
                instructions[off - 5] = ["nop"]
                instructions[off - 6] = ["nop"]
                instructions[off - 7] = ["nop"]
            } else if instructions[off - 6][0] == "cpy" && Int(instructions[off - 6][1]) != nil {
                // We've got a integer multiply, replace by mul follewed by add, and insert nop:s
                let mulSource = instructions[off - 2][2]
                let source = instructions[off][1]
                instructions[off - 1] = ["mul", source, mulSource]

                let target = instructions[off - 2][1]
                instructions[off] = ["add", target, source]
                instructions[off - 2] = ["nop"]
                instructions[off - 3] = ["nop"]
                instructions[off - 4] = ["nop"]
                instructions[off - 5] = ["nop"]
            }
        }
    }

    return instructions
}
