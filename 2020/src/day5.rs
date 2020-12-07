use std::collections::HashSet;
use std::convert::TryInto;

pub fn run(input: String) -> Vec<usize> {
    let taken_seats: HashSet<u32> = input.lines().map(to_num).collect();

    let last_seat: u32 = taken_seats.clone().into_iter().max().unwrap();

    let first_seat = to_num("FFFFFFFLLL");
    let all_seats: HashSet<u32> = (first_seat..=last_seat).collect();
    let empty_seats: HashSet<&u32> = all_seats.difference(&taken_seats).collect();
    let without_siblings: Vec<&&u32> = empty_seats.iter()
        .filter(|seat| !empty_seats.contains(&(**seat+1)) && !empty_seats.contains(&(**seat-1)))
        .collect();
    assert_eq!(without_siblings.len(), 1);


    return vec![
        last_seat.try_into().unwrap(),
        without_siblings.first().unwrap().clone().clone().clone().try_into().unwrap()
    ];
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
