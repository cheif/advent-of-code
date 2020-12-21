pub fn run(input: String) -> Vec<usize> {
    let mut lines = input.lines();
    let now: usize = lines.next().unwrap().parse().ok().unwrap();
    let raw_buses = lines.next().unwrap();
    let buses: Vec<usize> = raw_buses.split(",").map(|c| c.parse().ok()).flatten().collect();
    let mut time_to_next: Vec<(&usize, usize)> = buses.iter().map(|b| (b, next_departure(&now, b))).collect();
    time_to_next.sort_by(|lhs, rhs| lhs.1.cmp(&rhs.1));
    let next_bus = time_to_next[0];
    return vec![
        next_bus.0 * (next_bus.1 - now),
        earliest_seq(raw_buses)
    ];
}

type Bus = (usize, usize);
fn earliest_seq(buses: &str) -> usize {
    let with_offset: Vec<Bus> = buses.split(",").enumerate()
        .map(|(i, c)| c.parse::<usize>().map(|c| (c, i)).ok()).flatten().collect();

    let last = with_offset.iter().map(|(_, o)| o).max().unwrap();

    let big_m: usize = with_offset.iter().map(|(m, _)| m).product();
    let sum: usize = with_offset.iter().map(|(m, offset)| {
        let a = last - offset;
        let z = big_m/m;
        let y = (0..).find(|i| (i * z % m) == 1).unwrap();
        return a*y*z;
    }).sum();
    let timestamp = sum % big_m - last;
    for (b, o) in with_offset {
        assert_eq!((timestamp + o) % b, 0);
    }
    return timestamp;
}

fn next_departure(now: &usize, bus: &usize) -> usize {
    return (1..).map(|o| o * bus).find(|dpt| dpt > now).unwrap()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_run() {
        assert_eq!(run("939
7,13,x,x,59,x,31,19
".to_string()), [295, 1068781]);
    }

    #[test]
    fn test_earliest() {
        assert_eq!(earliest_seq("7,13,x,x,59,x,31,19"), 1068781);
        assert_eq!(earliest_seq("17,x,13,19"), 3417);
        assert_eq!(earliest_seq("67,7,59,61"), 754018);
        assert_eq!(earliest_seq("67,x,7,59,61"), 779210);
        assert_eq!(earliest_seq("67,7,x,59,61"), 1261476);
        assert_eq!(earliest_seq("1789,37,47,1889"), 1202161486);
    }
}
