use std::env;
mod day1;

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
        _ => {
            eprintln!("Not implemented yet");
            return;
        }
    };
    println!("{}", result)
}
