use core::ops::RangeInclusive;

pub fn run(input: String) -> Vec<usize> {
    let my_ticket = parse_my_ticket(&input);
    let dept_values: Vec<&(&str, usize)> = my_ticket.iter().filter(|(field, _)| field.starts_with("departure")).collect();
    assert_eq!(dept_values.len(), 6);
    return vec![
        run_first(&input),
        dept_values.iter().map(|(_, val)| val).product()
    ];
}

fn run_first(input: &str) -> usize {
    let inputs: Vec<&str> = input.split("\n\n").collect();
    let rules = parse_rules(inputs[0]);
    let others: Vec<Ticket> = inputs[2].lines().skip(1).map(parse_ticket).collect();
    let invalid_others: Vec<&usize> = others.iter().flatten().filter(|n| !rules.iter().any(|r| is_valid(r, n))).collect();
    return invalid_others.into_iter().sum();
}

fn parse_my_ticket(input: &str) -> Vec<(&str, usize)> {
    let mut inputs = input.split("\n\n");
    let rules = parse_rules(&inputs.next().unwrap());
    let mine = parse_ticket(inputs.next().unwrap().lines().nth(1).unwrap());
    let others: Vec<Ticket> = inputs.next().unwrap().lines().skip(1).map(parse_ticket).collect();
    let valid_others: Vec<Ticket> = others.into_iter().filter(|ticket| ticket.iter().all(|t| rules.iter().any(|r| is_valid(r, t)))).collect();
    let possible_indexes: Vec<usize> = (0..mine.len()).collect();
    let mut rule_mapping: Vec<(Vec<usize>, &Rule)> = rules.iter().map(|rule| {
        let indexes = valid_others.iter().fold(possible_indexes.clone(), |possible, ticket|
            possible.into_iter().filter(|index| is_valid(rule, &ticket[*index])).collect()
            );
        return (indexes, rule)
    }).collect();
    rule_mapping.sort_by(|(lhs, _), (rhs, _)| lhs.len().cmp(&rhs.len()));
    let mut taken: Vec<usize> = vec![];
    let final_rule_mapping: Vec<(usize, &Rule)> = rule_mapping.into_iter().map(|(indexes, rule)| {
        let index = indexes.iter().filter(|i| !taken.contains(i)).next().unwrap().clone();
        taken.push(index);
        return (index, rule);
    }).collect();
    return final_rule_mapping.iter().map(|(i, rule)| (rule.0, mine[*i])).collect();
}

type Rule<'a> = (&'a str, Vec<RangeInclusive<usize>>);
fn parse_rules(input: &str) -> Vec<Rule> {
    return input.lines()
        .map(|row| {
            let splitted_row: Vec<&str> = row.split(": ").collect();
            return (
                splitted_row[0],
                splitted_row[1].split(" or ").map(|p| {
                    let split: Vec<usize> = p.split("-").map(|s| s.parse().unwrap()).collect();
                    return split[0]..=split[1];
                }).collect()
                )
        }).collect()
}

fn is_valid(rule: &Rule, field: &usize) -> bool {
    return rule.1.iter().any(|range| range.contains(field));
}

type Ticket = Vec<usize>;
fn parse_ticket(line: &str) -> Ticket {
    return line.split(",").map(|c| c.parse().unwrap()).collect()
}


#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_run() {
        assert_eq!(run_first("class: 1-3 or 5-7
row: 6-11 or 33-44
seat: 13-40 or 45-50

your ticket:
7,1,14

nearby tickets:
7,3,47
40,4,50
55,2,20
38,6,12"), 71)
    }

    #[test]
    fn test_parse_my_ticket() {
        assert_eq!(parse_my_ticket("class: 0-1 or 4-19
row: 0-5 or 8-19
seat: 0-13 or 16-19

your ticket:
11,12,13

nearby tickets:
3,9,18
15,1,5
5,14,9"), vec![("row", 11), ("class", 12), ("seat", 13)])
    }
}
