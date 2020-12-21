use std::fmt;
use core::ops::Range;

pub fn run(input: String) -> Vec<usize> {
    let tiles: Vec<Tile> = input.split("\n\n").map(Tile::new).collect();
    let with_matches: Vec<_> = tiles.iter()
        .map(|tile| (tile, tile.neighbours(tiles.iter().filter(|t| t.id != tile.id).collect())))
        .collect();

    let corners: Vec<_> = with_matches.iter().filter(|(_, matches)| matches.len() == 2).collect();

    let size = (tiles.len() as f64).sqrt() as usize;
    let mut grid: Vec<Vec<Option<Tile>>> = vec![vec![None; size]; size];
    let (first_corner, neighbours) = corners[0];
    let top_left = first_corner.top_left_permutation(neighbours[0], neighbours[1]);
    grid[0][0] = Some(top_left);
    while grid.iter().flatten().flatten().count() != tiles.len() {
        let last = grid.iter().flatten().flatten().last().unwrap();
        if let Some(right) = last.tile_to_right(tiles.iter().filter(|t| t.id != last.id).collect()) {
            let (x, y) = idx(&grid, last);
            grid[x][y+1] = Some(right);
        } else {
            let row = idx(&grid, last).0;
            let tile = grid[row][0].as_ref().unwrap();
            let below = tile.tile_below(tiles.iter().filter(|t| t.id != tile.id).collect()).unwrap();
            let (x, y) = idx(&grid, &tile);
            grid[x+1][y] = Some(below);
        }
    }
    let joined = Grid::new_from_tiles(&grid.iter().map(|r| r.iter().flatten().map(|t| &t.grid).collect()).collect());

    let monster = Grid::new("                  #
#    ##    ##    ###
 #  #  #  #  #  #   ");
    let permutations = joined.permutations();
    let mut with_found: Vec<_> = permutations.iter().map(|g| (g, g.find_pattern(&monster))).collect();
    with_found.sort_by(|(_, lhs), (_, rhs)| rhs.cmp(&lhs));
    let (best, monsters) = with_found[0];
    let unoccupied = best.number_of('#') - monsters * monster.number_of('#');
    assert_eq!(&corners.len(), &4);
    return vec![
        corners.iter().map(|(tile, _)| tile.id).product(),
        unoccupied
    ];
}

fn idx(grid: &Vec<Vec<Option<Tile>>>, tile: &Tile) -> (usize, usize) {
    let mut with_idx = grid.iter().enumerate().map(move |(x, row)| row.iter().enumerate().map(move |(y, t)| t.as_ref().map(|t| ((x, y), t)))).flatten().flatten();
    return with_idx.find(|(_, t)| t.id == tile.id).unwrap().0;
}

type Edge = Vec<char>;

#[derive(Debug, Clone)]
struct Grid(Vec<Edge>);

#[derive(Debug, Clone)]
struct Tile {
    id: usize,
    grid: Grid,
}

impl Tile {
    fn new(input: &str) -> Self {
        let lines: Vec<&str> = input.lines().collect();
        let id: usize = lines[0].split(" ").nth(1).unwrap().split(":").nth(0).unwrap().parse().unwrap();

        return Tile {
            id: id,
            grid: Grid::new(&lines[1..].join("\n"))
        }
    }

    fn tile_to_right(&self, others: Vec<&Tile>) -> Option<Tile> {
        let mut permutations = others.iter().map(|o| o.permutations()).flatten();
        return permutations.find(|r| r.grid.left() == self.grid.right());
    }

    fn tile_below(&self, others: Vec<&Tile>) -> Option<Tile> {
        let mut permutations = others.iter().map(|o| o.permutations()).flatten();
        return permutations.find(|b| b.grid.top() == self.grid.bottom());
    }

    fn top_left_permutation(&self, below: &Tile, right: &Tile) -> Self {
        let my_permutations = self.permutations();
        let below_permutations = below.permutations();
        let right_permutations = right.permutations();

        let with_below: Vec<(&Tile, &Tile)> = my_permutations.iter()
            .map(|p| below_permutations.iter().find(|b| b.grid.top() == p.grid.bottom()).map(|b| (p, b)))
            .flatten()
            .collect();
        let with_right: Vec<(&Tile, &Tile, &Tile)> = with_below.into_iter()
            // This will probably break down when we start flipping things?
            .map(|(p, b)| right_permutations.iter().find(|r| r.grid.left() == p.grid.right()).map(|r| (p, b, r)))
            .flatten()
            .collect();
        return with_right[0].0.clone();
    }

    fn permutations(&self) -> Vec<Self> {
        return self.grid.permutations().into_iter().map(|grid| Tile { id: self.id, grid: grid }).collect();
    }

    fn neighbours<'a>(&self, others: Vec<&'a Tile>) -> Vec<&'a Tile> {
        let our_edges = self.grid.edges();
        return our_edges.iter().map(|edge| others.clone().into_iter().filter(|t| t.grid.edge_permutations().contains(edge)).collect::<Vec<&'a Tile>>()).flatten().collect();
    }
}

impl Grid {
    fn new_from_tiles(grid: &Vec<Vec<&Grid>>) -> Self {
        let mut rows: Vec<Edge> = vec![];
        for row in grid {
            for i in 1..row[0].0.len()-1 {
                let mut r: Vec<char> = vec![];
                for grid in row {
                    r.append(&mut grid.0[i].clone()[1..grid.0[0].len()-1].to_vec())
                }
                rows.push(r);
            }
        }
        return Grid(rows)
    }

    fn new(input: &str) -> Self {
        let lines: Vec<&str> = input.lines().collect();
        return Grid(lines.iter().map(|l| l.chars().collect()).collect())
    }

    fn permutations(&self) -> Vec<Self> {
        return vec![
            self.clone(),
            self.rotated(),
            self.rotated().rotated(),
            self.rotated().rotated().rotated(),
        ].iter()
            .map(|c| vec![c.clone(), c.flipped()])
            .flatten()
            .collect()
    }

    fn rotated(&self) -> Self {
        let mut rows = self.0.clone();
        rotate(&mut rows);
        return Grid(rows)
    }

    fn flipped(&self) -> Self {
        return Grid(self.0.iter().map(|r| r.clone().into_iter().rev().collect()).collect())
    }

    fn edges(&self) -> Vec<Edge> {
        return vec![
            self.top(),
            self.right(),
            self.bottom(),
            self.left()
        ]
    }

    fn top(&self) -> Edge {
        return self.0[0].clone();
    }

    fn right(&self) -> Edge {
        return self.0.iter().map(|r| r.last().unwrap().clone()).collect();
    }

    fn bottom(&self) -> Edge {
        return self.0[self.0.len() - 1].clone();
    }

    fn left(&self) -> Edge {
        return self.0.iter().map(|r| r.first().unwrap().clone()).collect();
    }

    fn edge_permutations(&self) -> Vec<Edge> {
        return self.edges().iter().map(|e| permutations(e)).flatten().collect();
    }

    fn find_pattern(&self, pattern: &Grid) -> usize {
        let mut no_matches = 0;
        for x in 0..self.0.len() {
            for y in 0..self.0[0].len() {
                if let Some(sub_grid) = self.subgrid(x..x+pattern.0.len(), y..y+pattern.0[0].len()) {
                    let matches = sub_grid.matches(pattern);
                    if matches {
                        no_matches += 1;
                    }
                }
            }
        }
        return no_matches;
    }

    fn subgrid(&self, x_range: Range<usize>, y_range: Range<usize>) -> Option<Self> {
        let mut rows: Vec<Vec<char>> = vec![];
        if x_range.end >= self.0.len() || y_range.end >= self.0[0].len() {
            return None;
        }
        for x in x_range.clone() {
            rows.push(self.0[x][y_range.clone()].to_vec());
        }
        if rows.len() != x_range.len() || rows[0].len() != y_range.len() {
            return None;
        }
        return Some(Grid(rows));
    }

    fn matches(&self, pattern: &Grid) -> bool {
        return self.0.iter().zip(pattern.0.clone()).all(|(s_row, p_row)|
                                                        s_row.iter().zip(p_row).all(|(&s, p)| match p {
                                                            '#' => s == '#',
                                                            _ => true
                                                        }))
    }

    fn number_of(&self, c: char) -> usize {
        return self.0.iter().flatten().filter(|&&s| s == c).count();
    }
}

impl fmt::Display for Grid {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        return write!(f, "{}", self.0.iter().map(|r| r.iter().collect::<String>()).collect::<Vec<String>>().join("\n"));
    }
}


fn rotate(matrix: &mut Vec<Vec<char>>) {
    matrix.reverse();
    for i in 1..matrix.len() {
        let (left, right) = matrix.split_at_mut(i);
        for (j, left_item) in left.iter_mut().enumerate().take(i) {
            std::mem::swap(&mut left_item[i], &mut right[0][j]);
        }
    }
}

fn permutations(edge: &Edge) -> Vec<Edge> {
    return vec![
        edge.clone(),
        edge.clone().into_iter().rev().collect()
    ];
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_run() {
        let input = std::fs::read_to_string("testdata/20").unwrap();
        assert_eq!(run(input), [20899048083289, 273]);
    }
}
