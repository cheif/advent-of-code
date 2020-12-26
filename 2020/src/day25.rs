pub fn run(input: String) -> Vec<usize> {
    let pub_keys: Vec<usize> = input.lines().map(|l| l.parse().unwrap()).collect();
    let card_pub = pub_keys[0];
    let door_pub = pub_keys[1];
    let card_loop = loop_size_for_pub_key(card_pub);
    let door_loop = loop_size_for_pub_key(door_pub);
    println!("{}", card_loop);
    println!("{}", door_loop);

    let enc_key = (0..card_loop).fold(1, |a, _| do_loop(a, door_pub));
    println!("{}", enc_key);
    return vec![
        enc_key
    ];
}

fn loop_size_for_pub_key(pub_key: usize) -> usize {
    let mut val = 1;
    for i in 1.. {
        val = do_loop(val, 7);
        if val == pub_key {
            return i;
        }
    }
    panic!();
}

fn do_loop(value: usize, subject: usize) -> usize {
    return value * subject % 20201227;
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_run() {
        assert_eq!(run("5764801
17807724".to_string()), [14897079]);
    }
}
