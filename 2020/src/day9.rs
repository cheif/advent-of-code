use std::str::FromStr;
use combinations::Combinations;

pub fn run(input: String) -> Vec<usize> {
    return run_with_len(input, 25);
}

fn run_with_len(input: String, preamble_len: usize) -> Vec<usize> {
    let numbers: Vec<usize> = input.lines().map(usize::from_str).flatten().collect();
    let invalid_number = find_invalid(&numbers, preamble_len);
    let range_of_sum = find_range(&numbers, invalid_number);
    return vec![
        invalid_number,
        range_of_sum.iter().min().unwrap() + range_of_sum.iter().max().unwrap()
    ]
}

fn find_invalid(numbers: &Vec<usize>, preamble_len: usize) -> usize {
    let mut preamble: Vec<usize> = numbers[0..=preamble_len].to_vec();
    for num in numbers[preamble_len..].to_vec() {
        if !has_valid_sums(num, &preamble) {
            return num;
        };
        preamble.remove(0);
        preamble.push(num);
    }
    return 0
}

fn find_range(numbers: &Vec<usize>, target_sum: usize) -> Vec<usize> {
    let mut start = 0;
    let mut end = 1;
    while end < numbers.len() {
        let range = &numbers[start..end];
        let sum: usize = range.iter().sum();
        if sum < target_sum {
            end += 1;
        } else if sum > target_sum {
            start += 1;
        } else {
            return range.to_vec();
        }
    }

    return vec![];
}

fn has_valid_sums(sum: usize, preamble: &Vec<usize>) -> bool {
    let combinations: Vec<_> = Combinations::new(preamble.to_vec(), 2).collect();
    let sums: Vec<usize> = combinations.iter().map(|n| n.iter().sum()).collect();
    return sums.contains(&sum);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_run() {
        assert_eq!(run_with_len("35
20
15
25
47
40
62
55
65
95
102
117
150
182
127
219
299
277
309
576".to_string(), 5), [127, 62]);
    }
}
