use cached::proc_macro::cached;
use cached::SizedCache;

pub fn run(input: String) -> Vec<usize> {
    let mut lines = input.lines();
    let player1 = parse_hand(&mut lines);
    let player2 = parse_hand(&mut lines);
    let (_, combat_hand) = combat(&player1, &player2);
    let (_, recursive_hand) = recursive_combat(&player1, &player2);

    return vec![
        combat_hand.iter().rev().zip(1..).map(|(c, m)| c * m).sum(),
        recursive_hand.iter().rev().zip(1..).map(|(c, m)| c * m).sum()
    ];
}

#[derive(Debug, Clone, PartialEq)]
enum Player {
    One, Two
}
type Hand = Vec<usize>;

fn combat(first_player: &Hand, second_player: &Hand) -> (Player, Hand) {
    let mut player1 = first_player.clone();
    let mut player2 = second_player.clone();
    while player1.len() > 0 && player2.len() > 0 {
        let p1 = player1.remove(0);
        let p2 = player2.remove(0);
        let (winner, mut cards) = if p1 > p2 { (&mut player1, vec![p1, p2]) } else { (&mut player2, vec![p2, p1]) };
        winner.append(&mut cards);
    }
    return if player1.len() == 0 { (Player::Two, player2) } else { (Player::One, player1) };
}


#[cached(
    type = "SizedCache<String, (Player, Hand)>",
    create = "{ SizedCache::with_size(10000) }",
    convert = r#"{ format!("{:?}{:?}", first_player, second_player) }"#
)]
fn recursive_combat(first_player: &Hand, second_player: &Hand) -> (Player, Hand) {
    let mut previous_configurations: Vec<(Hand, Hand)> = vec![];
    let mut player1 = first_player.clone();
    let mut player2 = second_player.clone();
    while player1.len() > 0 && player2.len() > 0 {
        let configuration = (player1.clone(), player2.clone());
        if previous_configurations.contains(&configuration) {
            return (Player::One, player1);
        }
        previous_configurations.push(configuration);
        let p1 = player1.remove(0);
        let p2 = player2.remove(0);
        let can_recurse = player1.len() >= p1 && player2.len() >= p2;
        let winning_player = if can_recurse { recursive_combat(&player1[..p1].to_vec(), &player2[..p2].to_vec()).0 } else if p1 > p2 { Player::One } else { Player::Two };

        let (winner, mut cards) = if winning_player == Player::One { (&mut player1, vec![p1, p2]) } else { (&mut player2, vec![p2, p1]) };
        winner.append(&mut cards);
    }
    return if player1.len() == 0 { (Player::Two, player2) } else { (Player::One, player1) };
}

fn parse_hand<'a>(lines: impl Iterator<Item=&'a str>) -> Hand {
    return lines.skip(1).take_while(|l| l.len() > 0).map(|l| l.parse().unwrap()).collect();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_run() {
        assert_eq!(run("Player 1:
9
2
6
3
1

Player 2:
5
8
4
7
10".to_string()), [306, 291]);
    }
}
