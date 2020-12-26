pub fn run(input: String) -> Vec<usize> {
    return vec![
        first(&input, 100)
    ];
}

fn first(input: &str, steps: usize) -> usize {
    let mut cups: Vec<usize> = input.chars().map(|c| c.to_digit(10).unwrap() as usize).collect();
    run_steps(&mut cups, steps);

    let rotation_index = cups.iter().position(|&c| c == 1).unwrap() + 1;
    cups.rotate_left(rotation_index);
    return cups[..cups.len()-1].iter().map(|c| c.to_string()).collect::<Vec<String>>().join("").parse().unwrap();
}

fn second(input: &str) -> usize {
    let mut cups: Vec<usize> = input.chars().map(|c| c.to_digit(10).unwrap() as usize).collect();
    let mut extra: Vec<usize> = (cups.len()..1_000).collect();
    cups.append(&mut extra);
    run_steps(&mut cups, 10);

    let rotation_index = cups.iter().position(|&c| c == 1).unwrap() + 1;
    cups.rotate_left(rotation_index);
    return cups[0] * cups[1];
}

fn run_steps(cups: &mut Vec<usize>, steps: usize) {
    let no_cups = cups.len();
    for _index in (0..steps).map(|o| o % no_cups) {
        let value = cups[0];
        let pickup: Vec<usize> = cups.drain(1..4).collect();
        println!("cups: {:?}", cups);

        let mut sorted = cups.clone();
        sorted.sort();
        let destination = sorted.iter().rfind(|&&i| i < value).unwrap_or(sorted.iter().max().unwrap());
        let destination_index = cups.iter().position(|v| v == destination).unwrap();
        println!("destination: {}", destination);
        let _: Vec<_> = cups.splice(destination_index+1..destination_index+1, pickup.into_iter()).collect();
        cups.rotate_left(1);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_ten() {
        assert_eq!(first("389125467", 10), 92658374);
    }

    #[test]
    fn test_hundred() {
        assert_eq!(first("389125467", 100), 67384529);
    }

    #[test]
    fn test_second() {
        assert_eq!(second("389125467"), 149245887792);
    }
}
