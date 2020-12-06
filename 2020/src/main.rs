use std::env;
mod day1;
mod day2;
mod day3;
mod day4;
mod day5;
mod day6;

fn main() {
    println!("Start");
    let args: Vec<String> = env::args().collect();
    println!("No args: {}", args.len());
    let problem: i32 = match args[1].parse() {
        Ok(n) => n,
        Err(_) => {
            eprintln!("Incorrect argument type");
            return;
        }
    };
    println!("Problem: {}", problem);
    let path = std::path::PathBuf::from(&args[2]);
    let input = std::fs::read_to_string(path)
        .expect("Could not read file");


    let result: String = match problem {
        1 => day1::run(input),
        2 => day1::run_second(input),
        3 => day2::run(input),
        4 => day2::run_second(input),
        5 => day3::run(input),
        6 => day3::run_second(input),
        7 => day4::run(input),
        8 => day4::run_second(input),
        9 => day5::run(input),
        10 => day5::run_second(input),
        11 => day6::run(input),
        12 => day6::run_second(input),
        _ => {
            eprintln!("Not implemented yet");
            return;
        }
    };
    println!("{}", result)
}
