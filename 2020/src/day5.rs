use std::collections::HashSet;

pub fn run(input: String) -> String {
    return input.lines().map(to_num).max().unwrap().to_string();
}

pub fn run_second(input: String) -> String {
    let taken_seats: HashSet<u32> = input.lines().map(to_num).collect();
    let first_seat = to_num("FFFFFFFLLL");
    let last_seat = to_num("BBBBBBBRRR");
    let all_seats: HashSet<u32> = (first_seat..=last_seat).collect();
    let empty_seats: HashSet<&u32> = all_seats.difference(&taken_seats).collect();
    let without_siblings: Vec<&&u32> = empty_seats.iter()
        .filter(|seat| !empty_seats.contains(&(**seat+1)) && !empty_seats.contains(&(**seat-1)))
        .collect();
    assert_eq!(without_siblings.len(), 1);

    return without_siblings.first().unwrap().to_string();
}

fn to_num(line: &str) -> u32 {
    let replaced = line
        .replace("B", "1")
        .replace("F", "0")
        .replace("R", "1")
        .replace("L", "0");
    return u32::from_str_radix(&replaced, 2).unwrap();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test() {
        assert_eq!(to_num("BFFFBBFRRR"), 567);
        assert_eq!(to_num("FFFBBBFRRR"), 119);
        assert_eq!(to_num("BBFFBBFRLL"), 820);
    }
}
