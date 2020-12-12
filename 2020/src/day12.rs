use regex::Regex;

pub fn run(input: String) -> Vec<usize> {
    let re = Regex::new(r"(\w)(\d*)").unwrap();
    let output = input.lines().map(|l| parse(l, &re)).fold(((0, 0), 0.0), reduction);
    let output2 = input.lines().map(|l| parse(l, &re)).fold(((0, 0), (10, 1)), reduction2);
    return vec![
        (output.0.0.abs() + output.0.1.abs()) as usize,
        (output2.0.0.abs() + output2.0.1.abs()) as usize
    ];
}

type State = ((isize, isize), f64);
fn reduction(state: State, ins: (char, usize)) -> State {
    let ((x, y), dir) = state;
    let (instruction, magnitude) = ins;
    let mag = magnitude as isize;
    return match instruction {
        'N' => ((x, y + mag), dir),
        'S' => ((x, y - mag), dir),
        'E' => ((x + mag, y), dir),
        'W' => ((x - mag, y), dir),
        'L' => ((x, y), dir + (mag as f64).to_radians()),
        'R' => ((x, y), dir - (mag as f64).to_radians()),
        'F' => ((x + (mag * dir.cos() as isize), y + (mag * dir.sin() as isize)), dir),
        _ => state
    }
}

type State2 = ((isize, isize), (isize, isize));
fn reduction2(state: State2, ins: (char, usize)) -> State2 {
    let (ship, wpt) = state;
    let (instruction, magnitude) = ins;
    let mag = magnitude as isize;
    let dir = (mag as f64).to_radians();
    let (d_sin, d_cos) = (dir.sin() as isize, dir.cos() as isize);
    return match instruction {
        'N' => (ship, (wpt.0, wpt.1 + mag)),
        'S' => (ship, (wpt.0, wpt.1 - mag)),
        'E' => (ship, (wpt.0 + mag, wpt.1)),
        'W' => (ship, (wpt.0 - mag, wpt.1)),
        'L' => (ship, (wpt.0 * d_cos - wpt.1 * d_sin, wpt.1 * d_cos + wpt.0 * d_sin)),
        'R' => (ship, (wpt.0 * d_cos + wpt.1 * d_sin, wpt.1 * d_cos - wpt.0 * d_sin)),
        'F' => ((ship.0 + wpt.0 * mag, ship.1 + wpt.1 * mag), wpt),
        _ => state
    }
}

fn parse(l: &str, re: &Regex) -> (char, usize) {
    let capture = re.captures_iter(l).next().unwrap();
    return (capture[1].parse().unwrap(), capture[2].parse().unwrap());
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_run() {
        assert_eq!(run("F10
N3
F7
R90
F11".to_string()), [25, 286]);
    }
}
