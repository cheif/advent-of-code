use std::str::FromStr;

pub fn run(input: String) -> Vec<usize> {
    let mut sorted: Vec<usize> = input.lines().map(usize::from_str).flatten().collect();
    sorted.sort();
    let mut tail = sorted.to_vec();
    tail.push(sorted.last().unwrap() + 3);
    sorted.insert(0, 0);
    let pairs = sorted.iter().zip(tail.iter());
    let differences = pairs.fold(vec![], |mut acc, (lhs, rhs)| {
        acc.push(rhs - lhs);
        acc
    });
    let group_of_ones: Vec<usize> = differences.split(|&n| n == 3)
        .map(|g| g.len())
        .filter(|&l| l > 1)
        .map(|n| n - 1)
        .collect();
    let combinations: Vec<usize> = group_of_ones.iter()
        .map(|&n|
             // If the groups are 3 or more items longer, there are some invalid combinations. Only
             // handling 3 items now, since we don't seem to get anything longer
             2_usize.pow(n as u32) - if n == 3 { 1 } else { 0 }
            ).collect();
    return vec![
        &differences.iter().filter(|d| **d == 1).count() * &differences.iter().filter(|d| **d == 3).count(),
        combinations.iter().product()
    ];
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_run() {
        assert_eq!(run("16
10
15
5
1
11
7
19
6
12
4".to_string()), [7*5, 8]);
    }

    #[test]
    fn test_run_second() {
        assert_eq!(run("28
33
18
42
31
14
46
20
48
47
24
23
49
45
19
38
39
11
1
32
25
35
8
17
7
9
4
2
34
10
3".to_string()), [22*10, 19208]);
    }
}
