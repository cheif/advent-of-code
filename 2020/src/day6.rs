use std::collections::HashSet;

pub fn run(input: String) -> Vec<usize> {
    let groups = input.split("\n\n");
    return vec![
        groups.clone().map(unique_answers).into_iter().sum(),
        groups.clone().map(all_answered_yes_count).into_iter().sum()
    ];
}

fn unique_answers(group: &str) -> usize {
    let mut chars: Vec<char> = group.chars().filter(|c| c.is_alphabetic()).collect();
    chars.sort();
    chars.dedup();
    return chars.len();
}

fn all_answered_yes_count(group: &str) -> usize {
    let answers: Vec<HashSet<char>> = group.lines().map(|l| l.chars().collect()).collect();
    let all_answered: Vec<&char> = answers.first().unwrap().iter().filter(|a| answers[1..].iter().all(|s| s.contains(a))).collect();
    return all_answered.len();
}


#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_unique() {
        assert_eq!(unique_answers("abc"), 3);
        assert_eq!(unique_answers("
a
b
c
"), 3);
        assert_eq!(unique_answers("
ab
ac
"), 3);
        assert_eq!(unique_answers("
a
a
a
a
"), 1);
        assert_eq!(unique_answers("b"), 1);
    }

    #[test]
    fn test_run() {
        assert_eq!(run("abc

a
b
c

ab
ac

a
a
a
a

b".to_string()), vec![11, 6]);
    }
}
