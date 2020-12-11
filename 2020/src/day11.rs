type Board = Vec<Vec<char>>;
pub fn run(input: String) -> Vec<usize> {
    let board: Board = input.lines().map(|l| l.chars().collect()).collect();
    return vec![
        equilibrium(&board, adjacent, 4).iter().flatten().filter(|&&s| s == '#').count(),
        equilibrium(&board, line_of_sight, 5).iter().flatten().filter(|&&s| s == '#').count()
    ]
}

fn equilibrium(board: &Board, get_near: fn(&Board, usize, usize) -> Vec<char>, tolerance: usize) -> Board {
    let mut prev = board.clone();
    loop {
        //print(&prev);
        let next = round(&prev, get_near, tolerance);
        if next == prev {
            return next;
        }
        prev = next;
    }
}

fn round(board: &Board, get_near: fn(&Board, usize, usize) -> Vec<char>, tolerance: usize) -> Board {
    let rows = 0..board.len();
    let columns = 0..board[0].len();
    return rows.map(|r| columns.clone().map(|c| {
        let curr = board[r][c];
        let adj = get_near(&board, r, c);
        let occupied_adj = adj.iter().filter(|&&s| s == '#').count();
        if curr == 'L' && occupied_adj == 0 {
            return '#';
        } else if curr == '#' && occupied_adj >= tolerance {
            return 'L';
        } else {
            return curr;
        }
    }).collect()).collect()
}

fn adjacent(board: &Board, r: usize, c: usize) -> Vec<char> {
    let rows = if r == 0 { r..=r+1 } else if r == board.len()-1 { r-1..=r } else { r-1..=r+1 };
    let cols = if c == 0 { c..=c+1 } else if c == board[0].len()-1 { c-1..=c } else { c-1..=c+1 };
    let pairs = rows.map(|r| cols.clone().map(move |c| (r, c))).flatten().filter(|(x, y)| !(*x == r && *y == c));
    return pairs.map(|(r, c)| board[r][c]).collect();
}

fn line_of_sight(board: &Board, r: usize, c: usize) -> Vec<char> {
    let rows: Vec<isize> = if r == 0 { vec![0, 1] } else if r == board.len()-1 { vec![-1, 0] } else { vec![-1, 0, 1] };
    let cols: Vec<isize> = if c == 0 { vec![0, 1] } else if c == board[0].len()-1 { vec![-1, 0] } else { vec![-1, 0, 1] };
    let directions: Vec<_> = rows.into_iter().map(|r| cols.clone().into_iter().map(move |c| (r, c))).flatten()
        .filter(|(x, y)| !(*x == 0 && *y == 0)).collect();
    return directions.into_iter()
        .map(|d| items_in_direction(board, d, (r, c)).into_iter().find(|&s| s != '.'))
        .flatten().collect();
}

fn items_in_direction(board: &Board, dir: (isize, isize), from: (usize, usize)) -> Vec<char> {
    let mut point = from;
    let mut points = vec![];
    while point.0 < board.len() && point.1 < board[0].len() {
        points.push(point);
        point = (((point.0 as isize) + dir.0) as usize, ((point.1 as isize) + dir.1) as usize);
    }
    points.remove(0);
    return points.iter().map(|(r, c)| board[*r][*c]).collect();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_run()  {
        assert_eq!(run("L.LL.LL.LL
LLLLLLL.LL
L.L.L..L..
LLLL.LL.LL
L.LL.LL.LL
L.LLLLL.LL
..L.L.....
LLLLLLLLLL
L.LLLLLL.L
L.LLLLL.LL".to_string()), [37, 26]);
    }
}

