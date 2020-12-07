use combinations::Combinations;

pub fn run(input: String) -> Vec<usize> {
    let numbers: Vec<usize> = input.lines().into_iter().map( |l| l.parse().ok()).filter_map( |e| e ).collect();
    return vec![
        get_result(&numbers, 2).unwrap(),
        get_result(&numbers, 3).unwrap(),
    ]
}

fn get_result(numbers: &Vec<usize>, combinations: usize) -> Option<usize> {
    let combinations: Vec<_> = Combinations::new(numbers.to_vec(), combinations).collect();
    for input in combinations {
        let sum: usize = input.iter().sum();
        if sum == 2020 {
            return Some(input.iter().product());
        }
    }
    eprintln!("Didn't find the sum");
    return None
}
