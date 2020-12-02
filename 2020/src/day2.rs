use core::ops::Range;
use regex::Regex;

pub fn run(input: String) -> String {
    let policies = parse_all(input);
    println!("Policies: {}", policies.len());
    let valid_policies: Vec<PwWithPolicy> = policies.into_iter().filter(|p| is_valid(p)).collect();
    return valid_policies.len().to_string();
}

pub fn run_second(input: String) -> String {
    let policies = parse_all(input);
    let valid_policies: Vec<PwWithPolicy> = policies.into_iter().filter(|p| is_valid_new_rules(p)).collect();
    return valid_policies.len().to_string();
}

fn parse_all(input: String) -> Vec<PwWithPolicy> {
    let re = Regex::new(r"^(\d*)-(\d*)\s(\w):\s(.*)").unwrap();
    return input.lines().into_iter().map(|l| parse(l, &re).unwrap()).collect();
}

fn parse(line: &str, re: &Regex) -> Option<PwWithPolicy> {
    let captures: Vec<regex::Captures> = re.captures_iter(&line).collect::<Vec<regex::Captures>>();
    let capture: Option<&regex::Captures> = captures.first();

    return capture.map(|c|
                       PwWithPolicy {
                           password: c[4].to_string(),
                           policy: Policy {
                               start: c[1].parse().unwrap(),
                               end: c[2].parse().unwrap(),
                               char: c[3].parse().unwrap()
                           }
                       }
                      )

}

fn is_valid(input: &PwWithPolicy) -> bool {
    let count = input.password.chars().filter(|c| c == &input.policy.char).count();
    let full_range = Range { start: input.policy.start, end: input.policy.end + 1 };
    let is_valid = full_range.contains(&count);
    return is_valid;
}

fn is_valid_new_rules(input: &PwWithPolicy) -> bool {
    let at_start = input.password.chars().nth(input.policy.start - 1).unwrap();
    let at_end = input.password.chars().nth(input.policy.end - 1).unwrap();
    let in_password = [at_start, at_end];
    let count = in_password.iter().filter(|c| c == &&input.policy.char).count();
    return count == 1
}

#[derive(Debug)]
struct Policy {
    start: usize,
    end: usize,
    char: char
}

#[derive(Debug)]
struct PwWithPolicy {
    password: String,
    policy: Policy
}
