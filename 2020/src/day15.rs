use std::collections::HashMap;

pub fn run(input: String) -> Vec<usize> {
    let numbers: Vec<usize> = input.split(",").map(|c| c.parse()).flatten().collect();
    return vec![
        at_turn(&numbers, 2020),
        at_turn(&numbers, 30000000)
    ];
}

fn at_turn(numbers: &Vec<usize>, turn: usize) -> usize {
    let mut spoken: HashMap<usize, usize> = HashMap::new();
    let mut next: usize = numbers.first().unwrap().clone();
    let mut this: usize = 0;
    for turn in 1..turn {
        if let Some(num) = numbers.get(turn) {
            this = *num;
        } else {
            let last_spoken = spoken.get(&next);
            this = match last_spoken {
                Some(age) => turn - 1 - age,
                None => 0
            };
        }
        spoken.insert(next, turn - 1);
        next = this;
        if turn % 1000000 == 0 {
            println!("turn: {}", turn);
        }
    }
    return this;
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_run() {
        assert_eq!(run("0,3,6".to_string()), [436, 175594]);
        assert_eq!(run("1,3,2".to_string()), [1, 2578]);
        assert_eq!(run("2,1,3".to_string()), [10, 3544142]);
        assert_eq!(run("1,2,3".to_string()), [27, 261214]);
        assert_eq!(run("2,3,1".to_string()), [78, 6895259]);
        assert_eq!(run("3,2,1".to_string()), [438, 18]);
        assert_eq!(run("3,1,2".to_string()), [1836, 362]);
    }
}
