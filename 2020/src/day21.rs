use std::collections::{HashMap, HashSet};
use regex::Regex;

pub fn run(input: String) -> Vec<usize> {
    let mut allergen_mapping: HashMap<String, HashSet<String>> = HashMap::new();

    let mapping = parse(&input);
    for (allergen, ingredients) in &mapping {
        if let Some(existing) = allergen_mapping.get(allergen) {
            let updated: HashSet<String> = existing.intersection(&ingredients).map(|s| s.to_owned()).collect();
            allergen_mapping.insert(allergen.to_owned(), updated);
        } else {
            allergen_mapping.insert(allergen.to_owned(), ingredients.to_owned());
        }
    }

    let allergens: Vec<String> = allergen_mapping.keys().map(|s| s.to_owned()).collect();
    while allergen_mapping.values().any(|v| v.len() > 1) {
        let resolved_ingredients: HashSet<String> = allergen_mapping.values().filter(|v| v.len() == 1).map(|v| v.iter().nth(0).unwrap().to_owned()).collect();
        for allergen in &allergens {
            let ingredients = allergen_mapping.get(allergen).unwrap();
            if ingredients.len() > 1 {
                let updated: HashSet<String> = ingredients.difference(&resolved_ingredients).map(|s| s.to_owned()).collect();
                allergen_mapping.insert(allergen.to_owned(), updated);
            }
        }
    }

    let mut pairs: Vec<(&String, &String)> = allergen_mapping.iter().map(|(a, v)| (a, v.iter().nth(0).unwrap())).collect();
    pairs.sort_by(|(lhs, _), (rhs, _)| lhs.cmp(&rhs));
    let with_allergens: Vec<&String> = pairs.into_iter().map(|(_, i)| i).collect();
    let ingredient_apparences: Vec<&str> = input.lines().map(|line| line.split(" ").take_while(|s| !s.starts_with("("))).flatten().collect();

    let without_allergen_apparences: Vec<&str> = ingredient_apparences.into_iter().filter(|i| !with_allergens.contains(&&i.to_string())).collect();

    println!("second task: {:?}", with_allergens.into_iter().map(|s| s.to_owned()).collect::<Vec<String>>().join(","));
    return vec![
        without_allergen_apparences.len()
    ];
}

fn parse(input: &str) -> Vec<(String, HashSet<String>)> {
    let re = Regex::new(r"(.*?)\s\(contains\s(.*?)\)").unwrap();
    return input.lines()
        .map(|line| {
            let capture = re.captures(line).unwrap();
            let ingredients: &HashSet<String> = &capture[1].split(" ").map(|s| s.to_owned()).collect();
            let allergens: Vec<&str> = capture[2].split(", ").collect();
            return allergens.into_iter().map(|a| (a.to_owned(), ingredients.to_owned())).collect::<Vec<(String, HashSet<String>)>>();
            /*
            return allergens.map(|allergen| (*allergen, *ingredients))
            */
        })
        .flatten()
        .collect();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_run() {
        assert_eq!(run("mxmxvkd kfcds sqjhc nhms (contains dairy, fish)
trh fvjkl sbzzf mxmxvkd (contains dairy)
sqjhc fvjkl (contains soy)
sqjhc mxmxvkd sbzzf (contains fish)".to_string()), [5]);
    }
}
