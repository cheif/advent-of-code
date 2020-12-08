use regex::Regex;

pub fn run(input: String) -> Vec<usize> {
    let re = Regex::new(r"^(\w*)\s(.*)").unwrap();
    let mut instructions: Vec<Instruction> = input.lines().map(|l| Instruction::from_str(l, &re)).flatten().collect();
    let first_acc = match run_instructions(&instructions) {
        Err(RunError::InfiniteLoop(acc)) => acc,
        Ok(_) => 0
    };
    for (offset, instruction) in instructions.clone().iter().enumerate() {
        let replacement = match instruction {
            Instruction::Jmp(arg) => Some(Instruction::Nop(*arg)),
            Instruction::Nop(arg) => Some(Instruction::Jmp(*arg)),
            Instruction::Acc(_) => None
        };
        if let Some(new) = replacement {
            let old = std::mem::replace(&mut instructions[offset], new);
            let result = run_instructions(&instructions);
            if let Ok(_) = result {
                break;
            }
            instructions[offset] = old;
        }
    }
    let second_acc = run_instructions(&instructions).ok().unwrap();
    return vec![
        first_acc as usize,
        second_acc as usize
    ];
}

fn run_instructions(instructions: &Vec<Instruction>) -> Result<i32, RunError> {
    let mut acc: i32 = 0;
    let mut visited: Vec<usize> = vec![];
    let mut pc: usize = 0;
    while pc < instructions.len() {
        visited.push(pc);
        acc = match instructions[pc] {
            Instruction::Acc(increase) => acc + increase,
            Instruction::Jmp(_) | Instruction::Nop(_) => acc
        };
        pc = match instructions[pc] {
            Instruction::Acc(_) | Instruction::Nop(_) => pc + 1,
            Instruction::Jmp(offset) => (pc as i32 + offset) as usize
        };
        if visited.contains(&pc) {
            return Err(RunError::InfiniteLoop(acc))
        }
    }
    return Ok(acc);
}

enum RunError {
    InfiniteLoop(i32)
}

#[derive(Debug, Clone)]
enum Instruction {
    Acc(i32),
    Jmp(i32),
    Nop(i32)
}

impl Instruction {
    fn from_str(s: &str, re: &Regex) -> Option<Self> {
        let capture = re.captures_iter(s).next()?;
        let val: i32 = capture[2].parse().ok()?;
        return match &capture[1] {
            "acc" => Some(Self::Acc(val)),
            "jmp" => Some(Self::Jmp(val)),
            "nop" => Some(Self::Nop(val)),
            _ => None
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_run() {
        assert_eq!(run("nop +0
acc +1
jmp +4
acc +3
jmp -3
acc -99
acc +1
jmp -4
acc +6".to_string()), [5, 8]);
    }
}
