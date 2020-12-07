use regex::Regex;

pub fn run(input: String) -> Vec<usize> {
    let re = Regex::new(r"^(\w*\s\w*)\sbags\scontain\s(.*)").unwrap();
    let contents_re = Regex::new(r"(\d)\s(\w*\s\w*)").unwrap();
    let stringy: Vec<StringyBag> = input.lines().map(|l| StringyBag::from_str(l, &re, &contents_re)).flatten().collect();
    let mut bags = Bag::from_stringy(stringy);
    let index = bags.iter().position(|r| r.name == "shiny gold").unwrap();
    let shiny_gold = bags.remove(index);
    let with_shiny_gold = bags.iter().filter(|b| b.contains_recursive(&shiny_gold));
    return vec![
        with_shiny_gold.count(),
        // Remove one so that we don't count with ourselves
        shiny_gold.number_of_children() - 1
    ];
}

#[derive(Debug, Clone)]
struct Bag {
    name: String,
    contains: Vec<(Bag, usize)>
}

impl Bag {
    fn from_stringy(bags: Vec<StringyBag>) -> Vec<Self> {
        let mut stringy = bags.to_vec();
        stringy.sort_by(|lhs, rhs| lhs.contains.len().cmp(&rhs.contains.len()));
        let mut out: Vec<Bag> = vec![];
        while stringy.len() > 0 {
            let existing = out.clone();
            let mut leaves: Vec<Bag> = stringy.iter().filter_map(|b| {
                let contains: Vec<(Bag, usize)> = b.contains.iter().map(|i| existing.iter().find(|o| o.name == *i.0).map(|b| (b.clone(), i.1))).flatten().collect();
                return if contains.len() == b.contains.len() {
                    Some(Bag { name: b.name.clone(), contains: contains })
                } else {
                    None
                }
            }).collect();
            for leave in &leaves {
                let index = stringy.iter().position(|r| r.name == leave.name).unwrap();
                stringy.remove(index);
            }
            out.append(&mut leaves);
        }
        return out;
    }

    fn contains_recursive(&self, bag: &Bag) -> bool {
        return self.name == bag.name || self.contains.iter().any(|b| b.0.contains_recursive(&bag))
    }

    fn number_of_children(&self) -> usize {
        return self.contains.iter().map(|b| b.1 * b.0.number_of_children()).sum::<usize>() + 1;
    }
}

#[derive(Debug, Clone)]
struct StringyBag {
    name: String,
    contains: Vec<(String, usize)>
}

impl StringyBag {
    fn from_str(s: &str, re: &Regex, contents_re: &Regex) -> Option<Self> {
        let capture = re.captures_iter(s).next()?;
        let contents: Vec<&str> = capture[2].split(", ").collect();
        let contains: Vec<(String, usize)> = contents.iter().map(|l| contents_re.captures_iter(l).next()).flatten().map(|c| (c[2].to_string(), c[1].parse().unwrap())).collect();
        Some(StringyBag {
            name: capture[1].to_string(),
            contains: contains
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_run() {
        assert_eq!(run("light red bags contain 1 bright white bag, 2 muted yellow bags.
dark orange bags contain 3 bright white bags, 4 muted yellow bags.
bright white bags contain 1 shiny gold bag.
muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
dark olive bags contain 3 faded blue bags, 4 dotted black bags.
vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
faded blue bags contain no other bags.
dotted black bags contain no other bags.".to_string()), [4, 32]);
    }

    #[test]
    fn test_run_example_two() {
        assert_eq!(run("shiny gold bags contain 2 dark red bags.
dark red bags contain 2 dark orange bags.
dark orange bags contain 2 dark yellow bags.
dark yellow bags contain 2 dark green bags.
dark green bags contain 2 dark blue bags.
dark blue bags contain 2 dark violet bags.
dark violet bags contain no other bags.".to_string()), [0, 126]);
    }
}
