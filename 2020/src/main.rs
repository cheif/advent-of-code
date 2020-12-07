use std::env;
use chrono;
use chrono::Datelike;

mod day1;
mod day2;
mod day3;
mod day4;
mod day5;
mod day6;
mod day7;

fn main() {
    let args: Vec<String> = env::args().collect();

    let offset = chrono::FixedOffset::east(5 * 3600);
    let today = chrono::Utc::today().with_timezone(&offset);

    let problem: u32 = args.get(1).unwrap_or(&String::from("")).parse().unwrap_or(today.day());
    let path = std::path::PathBuf::from(format!("input/{}", problem));
    let input = std::fs::read_to_string(path)
        .expect("Could not read input");


    let results: Vec<usize> = match problem {
        1 => day1::run(input),
        2 => day2::run(input),
        3 => day3::run(input),
        4 => day4::run(input),
        5 => day5::run(input),
        6 => day6::run(input),
        7 => day7::run(input),
        _ => {
            eprintln!("Not implemented yet");
            return;
        }
    };
    println!("Results for {}: {:?}", problem, results);
}
