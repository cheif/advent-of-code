use regex::Regex;
use std::collections::HashMap;

pub fn run(input: String) -> Vec<usize> {
    return vec![
        run_with_mask_strategy(&input, mask_value),
        run_with_mask_strategy(&input, mask_address)
    ];
}

type Instruction = (usize, usize);
fn run_with_mask_strategy(input: &String, strategy: fn(Instruction, &str) -> (Vec<usize>, usize)) -> usize {
    let lines: Vec<&str> = input.lines().collect();
    let mask_re = Regex::new(r"mask\s=\s(.*)").unwrap();
    let mut mask = mask_re.captures_iter(lines.iter().next().unwrap()).next().unwrap()[1].to_string();
    let re = Regex::new(r"mem\[(\d*)\]\s=\s(\d*)").unwrap();
    let mut mem: HashMap<usize, usize> = HashMap::new();
    for line in lines {
        if let Some(captured_mask) = get_mask(line, &mask_re) {
            mask = captured_mask;
            continue;
        } else {
            let instruction = get_instruction(line, &re);
            let masked = strategy(instruction, &mask);
            for addr in masked.0 {
                mem.insert(addr, masked.1);
            }
        }
    }
    return mem.values().sum();
}

fn get_mask(line: &str, re: &Regex) -> Option<String> {
    return re.captures_iter(line).next().map(|capture| capture[1].to_string());
}

fn get_instruction(line: &str, re: &Regex) -> (usize, usize) {
    let capture = re.captures_iter(line).next().unwrap();
    return (capture[1].parse().unwrap(), capture[2].parse().unwrap());
}

fn mask_value(ins: Instruction, mask: &str) -> (Vec<usize>, usize) {
    let binary = format!("{:0>36b}", ins.1);
    let masked: String = binary.chars().enumerate().map(|(i, v)| {
        let in_mask = mask.chars().nth(i).unwrap();
        return if in_mask == 'X' { v } else { in_mask };
    }).collect();
    let new = usize::from_str_radix(&masked, 2).unwrap();
    return (vec![ins.0], new);
}

fn mask_address(ins: Instruction, mask: &str) -> (Vec<usize>, usize) {
    let binary = format!("{:0>36b}", ins.0);
    let masked: String = binary.chars().enumerate().map(|(i, v)| {
        let in_mask = mask.chars().nth(i).unwrap();
        return if in_mask == '0' { v } else { in_mask };
    }).collect();
    let floating: Vec<usize> = masked.chars().enumerate().filter_map(|(i, c)| if c == 'X' {Some(i)} else { None }).collect();
    let mut permutations: Vec<Vec<char>> = vec![masked.chars().collect()];
    for index in floating {
        let new = permutations.iter().map(|p| {
            let mut zeroed = p.clone();
            let mut oned = p.clone();
            zeroed[index] = '0';
            oned[index] = '1';
            return vec![zeroed, oned];
        }).flatten().collect();
        permutations = new;
    }
    let addresses: Vec<usize> = permutations.into_iter()
        .map(|p| p.into_iter().collect::<String>())
        .map(|p| usize::from_str_radix(&p, 2).unwrap()).collect();
    return (addresses, ins.1);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_first() {
        assert_eq!(run_with_mask_strategy(&"mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
mem[8] = 11
mem[7] = 101
mem[8] = 0".to_string(), mask_value), 165);
    }

    #[test]
    fn test_run_two() {
        assert_eq!(run_with_mask_strategy(&"mask = 000000000000000000000000000000X1001X
mem[42] = 100
mask = 00000000000000000000000000000000X0XX
mem[26] = 1".to_string(), mask_address), 208);
    }
}
