use std::str::FromStr;

pub fn run(input: String) -> Vec<usize> {
    let tiles: Vec<_> = input.lines().map(parse).collect();
    let mut reduced: Vec<_> = tiles.iter().map(reduce).collect();
    reduced.sort();
    let mut without_duplicates = reduced.clone();
    without_duplicates.dedup();
    let occurences: Vec<_> = without_duplicates.iter().map(|tile| reduced.iter().filter(|t| *t == tile).count()).collect();
    let flipped = occurences.iter().filter(|o| *o % 2 == 1).count();
    return vec![
        flipped
    ];
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

#[derive(Debug, PartialEq, Clone, PartialOrd, Ord, Eq)]
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
wseweeenwnesenwwwswnew".to_string()), [10]);
    }
}
