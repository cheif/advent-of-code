use std::str::FromStr;
use std::iter::FromIterator;
use std::collections::{HashSet, HashMap};

pub fn run(input: String) -> Vec<usize> {
    let tiles: Vec<_> = input.lines().map(parse).collect();
    let mut reduced: Vec<_> = tiles.iter().map(reduce).collect();
    reduced.sort();
    let black: Vec<&Tile> = occurences(&reduced).into_iter().filter_map(|(t, o)| if o % 2 == 1 { Some(t) } else { None }).collect();
    return vec![
        black.len(),
        mutate(&black).len()
    ];
}

fn mutate(tiles: &Vec<&Tile>) -> Vec<Tile> {
    let mut current: HashSet<Tile> = HashSet::from_iter(tiles.clone().into_iter().map(|t| t.clone()));
    for day in 1..=100 {
        let old = current.clone();
        let with_neighbours: HashSet<(&Tile, Vec<Tile>)> = old.iter().map(|t| (t, neighbours(t))).collect();
        let to_remove: HashSet<&Tile> = with_neighbours.iter().filter_map(|(t, n)| {
            let black_neighbours = n.iter().filter(|n| old.contains(*n)).count();
            return match black_neighbours {
                1 | 2 => None,
                _ => Some(t.clone())
            };
        }).collect();
        let neighbours: Vec<Tile> = with_neighbours.into_iter()
            .map(|(_, n)| n).flatten()
            .filter(|t| !old.contains(t)).collect();
        let with_occurences = occurences(&neighbours);
        let to_add: HashSet<Tile> = with_occurences.into_iter()
            .filter_map(|(tile, occ)| if occ == 2 { Some(tile) } else { None })
            .map(|t| t.clone()).collect();

        current = old
            .union(&to_add)
            .collect::<HashSet<&Tile>>()
            .difference(&to_remove)
            .map(|t| t.clone().clone()).collect();


        if day <= 10 || day % 10 == 0 {
            println!("Day {}: {}", day, current.len());
            //println!("To remove {:?}", to_remove.len());
            //println!("To add {:?}", to_add.len());
        }
    }
    return current.into_iter().collect();
}

fn occurences(tiles: &Vec<Tile>) -> HashMap<&Tile, usize> {
    let mut res = HashMap::new();
    for tile in tiles {
        let counter = res.entry(tile).or_insert(0);
        *counter += 1;
    }
    return res;
}

type Tile = Vec<Dir>;
fn parse(line: &str) -> Tile {
    let mut tile: Tile = vec![];
    let mut i = 0;
    while i < line.len() {
        if let Ok(dir) = Dir::from_str(&line[i..i+1]) {
            tile.push(dir);
            i += 1;
        } else {
            let dir = Dir::from_str(&line[i..i+2]).unwrap();
            tile.push(dir);
            i += 2;
        }
    }
    return tile;
}

fn neighbours(tile: &Tile) -> Vec<Tile> {
    return vec![Dir::E, Dir::W, Dir::SE, Dir::SW, Dir::NW, Dir::NE].iter()
        .map(|d| {
            let mut new = tile.clone();
            new.push(d.clone());
            return new
        })
        .map(|t| reduce(&t))
        .collect();
}

fn reduce(tile: &Tile) -> Tile {
    let easts = tile.iter().filter(|&d| *d == Dir::E).count();
    let southeasts = tile.iter().filter(|&d| *d == Dir::SE).count();
    let southwests = tile.iter().filter(|&d| *d == Dir::SW).count();
    let wests = tile.iter().filter(|&d| *d == Dir::W).count();
    let northwests = tile.iter().filter(|&d| *d == Dir::NW).count();
    let northeasts = tile.iter().filter(|&d| *d == Dir::NE).count();
    let mut reduced: Tile = vec![];
    if easts > wests {
        reduced.append(&mut (wests..easts).map(|_| Dir::E).collect())
    } else {
        reduced.append(&mut (easts..wests).map(|_| Dir::W).collect())
    }
    if southeasts > northwests {
        reduced.append(&mut (northwests..southeasts).map(|_| Dir::SE).collect())
    } else {
        reduced.append(&mut (southeasts..northwests).map(|_| Dir::NW).collect())
    }
    if northeasts > southwests {
        reduced.append(&mut (southwests..northeasts).map(|_| vec![Dir::E, Dir::NW]).flatten().collect())
    } else {
        reduced.append(&mut (northeasts..southwests).map(|_| vec![Dir::W, Dir::SE]).flatten().collect())
    }
    reduced.sort();
    if reduced == *tile {
        return reduced
    } else {
        return reduce(&reduced)
    }
}

#[derive(Debug, PartialEq, Clone, PartialOrd, Ord, Eq, Hash)]
enum Dir {
    E,
    W,
    SE,
    SW,
    NW,
    NE
}

impl FromStr for Dir {
    type Err = ();
    fn from_str(input: &str) -> Result<Self, Self::Err> {
        match input {
            "e" => Ok(Dir::E),
            "se" => Ok(Dir::SE),
            "sw" => Ok(Dir::SW),
            "w" => Ok(Dir::W),
            "nw" => Ok(Dir::NW),
            "ne" => Ok(Dir::NE),
            _ => Err(())
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_run() {
        assert_eq!(run("sesenwnenenewseeswwswswwnenewsewsw
neeenesenwnwwswnenewnwwsewnenwseswesw
seswneswswsenwwnwse
nwnwneseeswswnenewneswwnewseswneseene
swweswneswnenwsewnwneneseenw
eesenwseswswnenwswnwnwsewwnwsene
sewnenenenesenwsewnenwwwse
wenwwweseeeweswwwnwwe
wsweesenenewnwwnwsenewsenwwsesesenwne
neeswseenwwswnwswswnw
nenwswwsewswnenenewsenwsenwnesesenew
enewnwewneswsewnwswenweswnenwsenwsw
sweneswneswneneenwnewenewwneswswnese
swwesenesewenwneswnwwneseswwne
enesenwswwswneneswsenwnewswseenwsese
wnwnesenesenenwwnenwsewesewsesesew
nenewswnwewswnenesenwnesewesw
eneswnwswnwsenenwnwnwwseeswneewsenese
neswnwewnwnwseenwseesewsenwsweewe
wseweeenwnesenwwwswnew".to_string()), [10, 2208]);
    }
}
