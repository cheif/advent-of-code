
pub fn run(input: String) -> Vec<usize> {
    let all_strategies: Vec<Strategy> = vec![
        Strategy { right: 1, down: 1 },
        Strategy { right: 3, down: 1 },
        Strategy { right: 5, down: 1 },
        Strategy { right: 7, down: 1 },
        Strategy { right: 1, down: 2 }
    ];
    return vec![
        trees_for_strategy(&input, &Strategy { right: 3, down: 1 }),
        all_strategies.iter().map(|strategy| trees_for_strategy(&input, strategy)).product()
    ];
}

#[derive(Debug)]
struct Strategy {
    right: usize,
    down: usize
}

fn trees_for_strategy(input: &String, strategy: &Strategy) -> usize {
    let rows: Vec<&str> = input.lines().step_by(strategy.down).collect();
    let offsets = rows.iter().enumerate().map(|(offset, _)| offset * strategy.right);
    let has_trees = rows.iter().zip(offsets).filter(|(row, offset)| has_tree(row, offset)).count();
    return has_trees;
}

fn has_tree(row: &str, offset: &usize) -> bool {
    let index = offset % row.len();
    return row.chars().nth(index).unwrap() == '#';
}
