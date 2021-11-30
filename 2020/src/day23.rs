pub fn run(input: String) -> Vec<usize> {
    return vec![
        first(&input, 100),
        second(&input)
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
    let mut extra: Vec<usize> = (cups.len()+1..=1_000_000).collect();
    cups.append(&mut extra);
    run_steps(&mut cups, 10_000);

    let rotation_index = cups.iter().position(|&c| c == 1).unwrap() + 1;
    cups.rotate_left(rotation_index);
    println!("rotated: {:?}", cups[..5].to_vec());
    return cups[0] * cups[1];
}

fn run_steps(cups: &mut Vec<usize>, steps: usize) {
    let no_cups = cups.len();
    println!("no_cups: {}", no_cups);
    for _index in (0..steps).map(|o| o % no_cups) {
        if is_sorted(&cups[..4]) && cups[no_cups-2] == cups[0] - 1 {
            println!("shortcircuit");
        } else {
            println!("head: {:?}", cups[..9].to_vec());
            println!("tail: {:?}", cups[no_cups-9..].to_vec());
        }
        let value = cups[0];
        let pickup: Vec<usize> = cups.drain(1..4).collect();
        let mut sorted_pickup: Vec<_> = pickup.clone();
        sorted_pickup.sort();
        let mut destination = value - 1;
        while pickup.contains(&destination) || destination == 0 {
            if destination == 0 {
                destination = no_cups;
            } else {
                destination -= 1;
            }
        }
        //println!("cups: {:?}", cups);

        //let mut sorted = cups.clone();
        //sorted.sort();
        //let destination = sorted.iter().rfind(|&&i| i < value).unwrap_or(sorted.iter().max().unwrap());
        println!("value: {}", value);
        println!("pickup: {:?}", pickup);
        println!("destination: {}", destination);
        let destination_index = cups.iter().position(|v| *v == destination).unwrap();
        let _: Vec<_> = cups.splice(destination_index+1..destination_index+1, pickup.into_iter()).collect();
        cups.rotate_left(1);
    }
}

fn is_sorted<T>(data: &[T]) -> bool
where
    T: Ord,
{
    data.windows(2).all(|w| w[0] <= w[1])
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
