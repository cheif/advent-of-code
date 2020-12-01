use combinations::Combinations;

pub fn run(input: String) -> String {
    let numbers: Vec<i32> = input.lines().into_iter().map( |l| l.parse().ok()).filter_map( |e| e ).collect();
    return match get_result(numbers, 2) {
        Some(number) => number.to_string(),
        None => String::from("Couldn't find anything")
    }
}

pub fn run_second(input: String) -> String {
    let numbers: Vec<i32> = input.lines().into_iter().map( |l| l.parse().ok()).filter_map( |e| e ).collect();
    return match get_result(numbers, 3) {
        Some(number) => number.to_string(),
        None => String::from("Couldn't find anything")
    }
}

fn get_result(numbers: Vec<i32>, combinations: usize) -> Option<i32> {
    let combinations: Vec<_> = Combinations::new(numbers, combinations).collect();
    for input in combinations {
        let sum: i32 = input.iter().sum();
        if sum == 2020 {
            return Some(input.iter().product());
        }
    }
    eprintln!("Didn't find the sum");
    return None
}
