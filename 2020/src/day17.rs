use std::convert::TryFrom;

pub fn run(input: String) -> Vec<usize> {
    let mut state: NormalState = State::new(&input);
    let mut hyper_state: HyperState = State::new(&input);
    for _i in 1..=6 {
        //state.print();
        state = state.update();
        //hyper_state.print();
        hyper_state = hyper_state.update();
    }
    //state.print();
    //hyper_state.print();
    return vec![
        state.iter().flatten().flatten().filter(|&&v| v).count(),
        hyper_state.iter().flatten().flatten().flatten().filter(|&&v| v).count()
    ];
}

trait State<Point> {
    fn new(input: &str) -> Self;
    fn value<'a>(&'a self, point: &Point) -> Option<&'a bool>;
    fn print(&self);
    fn neighbouring_points(&self, point: &Point) -> Vec<Point>;
    fn expanded(&self) -> Self;
    fn all_points(&self) -> Vec<Point>;
    fn set(&mut self, value: bool, point: &Point);
    fn point_old_dimensions(&self, point: &Point) -> Point;

    fn update(&self) -> Self where Self: Sized {
        let mut new = self.expanded();
        for new_point in new.all_points() {
            // Since the old state has different dimensions, we need to transform the
            // coordinates
            let point = self.point_old_dimensions(&new_point);
            let active = self.neighbouring_points(&point).iter()
                .map(|p| self.value(p)).flatten()
                .filter(|&&v| v).count();
            let this = self.value(&point).unwrap_or(&false);
            let value = (*this && (2..=3).contains(&active)) || !this && active == 3;
            //println!("point: {:?}, active: {}, this: {}, new: {}", point, active, this, value);
            //println!("neighbours: {:?}", my_neighbours);
            new.set(value, &new_point);

        }
        return new;
    }

}

type NormalPoint = (isize, isize, isize);
type NormalState = Vec<Vec<Vec<bool>>>;

impl State<NormalPoint> for NormalState {
    fn new(input: &str) -> Self {
        return vec![
            input.lines().map(|l| l.chars().map(|c| c == '#').collect()).collect()
        ]
    }

    fn value<'a>(&'a self, point: &NormalPoint) -> Option<&'a bool> {
        return self.get(usize::try_from(point.2).ok()?)?
            .get(usize::try_from(point.1).ok()?)?
            .get(usize::try_from(point.0).ok()?)
    }

    fn print(&self) {
        for (z, plane) in self.iter().enumerate() {
            println!("z={}", z);
            for row in plane {
                println!("{}", row.iter().map(|&v| if v { return '#' } else { return '.' }).collect::<String>());
            }
        }
    }

    fn neighbouring_points(&self, point: &NormalPoint) -> Vec<NormalPoint> {
        return (point.0-1..=point.0+1)
            .map(|x| (point.1-1..=point.1+1)
                 .map(|y| (point.2-1..=point.2+1).map(|z| (x, y, z)).collect())
                 .collect::<Vec<Vec<NormalPoint>>>())
            .flatten()
            .flatten()
            .filter(|p| !(p.0 == point.0 && p.1 == point.1 && p.2 == point.2))
            .collect();
    }

    fn expanded(&self) -> Self {
        let new_planes = self.len() + 2;
        let new_rows = self[0].len() + 2;
        let new_cols = self[0][0].len() + 2;

        return vec![vec![vec![false; new_cols]; new_rows]; new_planes];
    }

    fn all_points(&self) -> Vec<NormalPoint> {
        let planes = self.len();
        let rows = self[0].len();
        let cols = self[0][0].len();
        return (0..cols).map(move |x| (0..rows).map(move |y| (0..planes).map(move |z| (x as isize, y as isize, z as isize))))
            .flatten().flatten().collect();
    }

    fn set(&mut self, value: bool, point: &NormalPoint) {
        self[point.2 as usize][point.1 as usize][point.0 as usize] = value;
    }

    fn point_old_dimensions(&self, point: &NormalPoint) -> NormalPoint {
        return (point.0 - 1, point.1 - 1, point.2 - 1);
    }
}

type HyperPoint = (isize, isize, isize, isize);
type HyperState = Vec<Vec<Vec<Vec<bool>>>>;

impl State<HyperPoint> for HyperState {
    fn new(input: &str) -> Self {
        return vec![
            vec![
                input.lines().map(|l| l.chars().map(|c| c == '#').collect()).collect()
            ]
        ]
    }

    fn value<'a>(&'a self, point: &HyperPoint) -> Option<&'a bool> {
        return self.get(usize::try_from(point.3).ok()?)?
            .get(usize::try_from(point.2).ok()?)?
            .get(usize::try_from(point.1).ok()?)?
            .get(usize::try_from(point.0).ok()?)
    }

    fn print(&self) {
        for (w, ws) in self.iter().enumerate() {
            for (z, plane) in ws.iter().enumerate() {
                println!("z={}, w={}", z, w);
                for row in plane {
                    println!("{}", row.iter().map(|&v| if v { return '#' } else { return '.' }).collect::<String>());
                }
            }
        }
    }

    fn neighbouring_points(&self, point: &HyperPoint) -> Vec<HyperPoint> {
        return (point.0-1..=point.0+1)
            .map(move |x| (point.1-1..=point.1+1)
                 .map(move |y| (point.2-1..=point.2+1)
                      .map(move |z| (point.3-1..=point.3+1).map(move |w| (x, y, z, w))
                          ).flatten()
                     ).flatten()
                ).flatten()
            .filter(|p| !(p.0 == point.0 && p.1 == point.1 && p.2 == point.2 && p.3 == point.3))
            .collect();
    }

    fn expanded(&self) -> Self {
        let new_ws = self.len() + 2;
        let new_planes = self[0].len() + 2;
        let new_rows = self[0][0].len() + 2;
        let new_cols = self[0][0][0].len() + 2;

        return vec![vec![vec![vec![false; new_cols]; new_rows]; new_planes]; new_ws];
    }

    fn all_points(&self) -> Vec<HyperPoint> {
        let ws = self.len();
        let planes = self[0].len();
        let rows = self[0][0].len();
        let cols = self[0][0][0].len();
        return (0..cols).map(move |x| (0..rows).map(move |y| (0..planes).map(move |z| (0..ws).map(move |w| (x as isize, y as isize, z as isize, w as isize)))))
            .flatten().flatten().flatten().collect();
    }

    fn set(&mut self, value: bool, point: &HyperPoint) {
        self[point.3 as usize][point.2 as usize][point.1 as usize][point.0 as usize] = value;
    }

    fn point_old_dimensions(&self, point: &HyperPoint) -> HyperPoint {
        return (point.0 - 1, point.1 - 1, point.2 - 1, point.3 - 1);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_run() {
        assert_eq!(run(".#.
..#
###".to_string()), [112, 848]);
    }
}
