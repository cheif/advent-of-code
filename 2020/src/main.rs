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
mod day8;
mod day9;
mod day10;
mod day11;
mod day12;
mod day13;
mod day14;
mod day15;
mod day16;
mod day17;
mod day18;
mod day19;
mod day20;
mod day21;
mod day22;
mod day23;
mod day24;
mod day25;

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
        8 => day8::run(input),
        9 => day9::run(input),
        10 => day10::run(input),
        11 => day11::run(input),
        12 => day12::run(input),
        13 => day13::run(input),
        14 => day14::run(input),
        15 => day15::run(input),
        16 => day16::run(input),
        17 => day17::run(input),
        18 => day18::run(input),
        19 => day19::run(input),
        20 => day20::run(input),
        21 => day21::run(input),
        22 => day22::run(input),
        23 => day23::run(input),
        24 => day24::run(input),
        25 => day25::run(input),
        _ => {
            eprintln!("Not implemented yet");
            return;
        }
    };
    println!("Results for {}: {:?}", problem, results);
}
