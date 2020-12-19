use std::collections::HashMap;

pub fn run(input: String) -> Vec<usize> {
    let split: Vec<&str> = input.split("\n\n").collect();
    let rule_strings: Vec<&str> = split[0].lines().collect();
    let rules = rules_from(rule_strings.clone(), &HashMap::new());
    let rules_replaced = rules_from(replace_rules(rule_strings.clone()), &HashMap::new());
    let messages: Vec<&str> = split[1].lines().collect();
    //println!("rules: {:?}", rules);
    return vec![
        valid(&messages, &rules),
        valid(&messages, &rules_replaced)
    ];
}

fn valid(messages: &Vec<&str>, rules: &HashMap<usize, Rule>) -> usize {
    //println!("rule 0: {:?}", rule_zero);
    let rule = &rules[&0];
    let valid = messages.iter().filter(|m| rule.is_valid(m, rules)).count();
    /*
    for msg in messages.clone() {
        let is_valid = rule_zero.is_valid(msg);
        //println!("{} -> {}", msg, is_valid);
    }
    */
    return valid;
}

fn replace_rules(lines: Vec<&str>) -> Vec<&str> {
    return lines.into_iter().map(|l| match l.split(":").next().unwrap() {
        "8" => "8: 42 | 42 8",
        "11" => "11: 42 31 | 42 11 31",
        _ => l
    }).collect();
}

fn rules_from(lines: Vec<&str>, others: &HashMap<usize, Rule>) -> HashMap<usize, Rule> {
    let mut result = HashMap::new();
    for line in &lines {
        let split: Vec<&str> = line.split(": ").collect();
        let rule = rule_from(split[1], others);
        result.insert(split[0].parse().unwrap(), rule);
    }

    if &result.len() == &lines.len() {
        return result;
    } else {
        return rules_from(lines, &result);
    }
}

fn rule_from(line: &str, others: &HashMap<usize, Rule>) -> Rule {
    let chars: Vec<char> = line.chars().collect();
    if chars[0] == '"' {
        return Rule::Char(chars[1]);
    }

    let or_split: Vec<&str> = line.split(" | ").collect();
    if or_split.len() > 1 {
        let lhs = rule_from(or_split[0], others);
        let rhs = rule_from(or_split[1], others);
        return Rule::Or(Box::new(lhs), Box::new(rhs));
    }
    let sub_rules: Vec<usize> = line.split(" ").map(|c| c.parse::<usize>().unwrap()).collect();
    return Rule::SubRules(sub_rules);
}

#[derive(Debug, Clone)]
enum Rule {
    Char(char),
    Or(Box<Rule>, Box<Rule>),
    SubRules(Vec<usize>)
}

impl Rule {
    fn is_valid(&self, msg: &str, others: &HashMap<usize, Rule>) -> bool {
        let result = self.validate(msg, others);
        //println!("self: {:?}, {:?}", self, others);
        //println!("is_valid: {} => {:?}", msg, result);
        return match result {
            Some(consumed) => consumed == msg.len(),
            None => false
        }
    }

    fn validate(&self, msg: &str, others: &HashMap<usize, Rule>) -> Option<usize> {
        let result = match self {
            Rule::Char(c) => if msg.starts_with(&c.to_string()) { Some(1) } else { None },
            Rule::Or(lhs, rhs) => lhs.validate(&msg, others).or(rhs.validate(&msg, others)),
            Rule::SubRules(sub) => {
                let mut i = 0;
                for rule in sub.iter().map(|n| &others[n]) {
                    match rule.validate(&msg[i..], others) {
                        Some(consumed) => i += consumed,
                        None => return None
                    }
                }
                return Some(i)
            }
        };
        //println!("validate: {}, {:?} => {:?}", msg, self, result);
        return result;
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    //#[test]
    fn test_run() {
        assert_eq!(run(r#"0: 4 1 5
1: 2 3 | 3 2
2: 4 4 | 5 5
3: 4 5 | 5 4
4: "a"
5: "b"

ababbb
bababa
abbbab
aaabbb
aaaabbb"#.to_string()), [2, 2]);
    }

    //#[test]
    fn test_run_second() {
        assert_eq!(run(r#"42: 9 14 | 10 1
9: 14 27 | 1 26
10: 23 14 | 28 1
1: "a"
11: 42 31
5: 1 14 | 15 1
19: 14 1 | 14 14
12: 24 14 | 19 1
16: 15 1 | 14 14
31: 14 17 | 1 13
6: 14 14 | 1 14
2: 1 24 | 14 4
0: 8 11
13: 14 3 | 1 12
15: 1 | 14
17: 14 2 | 1 7
23: 25 1 | 22 14
28: 16 1
4: 1 1
20: 14 14 | 1 15
3: 5 14 | 16 1
27: 1 6 | 14 18
14: "b"
21: 14 1 | 1 14
25: 1 1 | 1 14
22: 14 14
8: 42
26: 14 22 | 1 20
18: 15 15
7: 14 5 | 1 21
24: 14 1

abbbbbabbbaaaababbaabbbbabababbbabbbbbbabaaaa
bbabbbbaabaabba
babbbbaabbbbbabbbbbbaabaaabaaa
aaabbbbbbaaaabaababaabababbabaaabbababababaaa
bbbbbbbaaaabbbbaaabbabaaa
bbbababbbbaaaaaaaabbababaaababaabab
ababaaaaaabaaab
ababaaaaabbbaba
baabbaaaabbaaaababbaababb
abbbbabbbbaaaababbbbbbaaaababb
aaaaabbaabaaaaababaa
aaaabbaaaabbaaa
aaaabbaabbaaaaaaabbbabbbaaabbaabaaa
babaaabbbaaabaababbaabababaaab
aabbbbbaabbbaaaaaabbbbbababaaaaabbaaabba"#.to_string()), [3, 12]);
    }

    //#[test]
    fn test_run_single() {
        assert_eq!(run(r#"42: 9 14 | 10 1
9: 14 27 | 1 26
10: 23 14 | 28 1
1: "a"
11: 42 31
5: 1 14 | 15 1
19: 14 1 | 14 14
12: 24 14 | 19 1
16: 15 1 | 14 14
31: 14 17 | 1 13
6: 14 14 | 1 14
2: 1 24 | 14 4
0: 8 11
13: 14 3 | 1 12
15: 1 | 14
17: 14 2 | 1 7
23: 25 1 | 22 14
28: 16 1
4: 1 1
20: 14 14 | 1 15
3: 5 14 | 16 1
27: 1 6 | 14 18
14: "b"
21: 14 1 | 1 14
25: 1 1 | 1 14
22: 14 14
8: 42
26: 14 22 | 1 20
18: 15 15
7: 14 5 | 1 21
24: 14 1

babbbbaabbbbbabbbbbbaabaaabaaa"#.to_string()), [0, 1]);
    }
}
