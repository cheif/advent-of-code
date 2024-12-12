import AOC2024
import Testing

@Suite
struct Day1 {
    @Test
    func p1() {
        #expect(day1.part1(input: """
3   4
4   3
2   5
1   3
3   9
3   3
""") == 11)
    }

    @Test
    func p2() {
        #expect(day1.part2(input: """
3   4
4   3
2   5
1   3
3   9
3   3
""") == 31)
    }
}

struct Day2 {
    let input = """
7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
"""
    @Test
    func p1() {
        #expect(day2.part1(input: input) == 2)
    }

    @Test
    func p2() {
        #expect(day2.part2(input: input) == 4)
    }
}

struct Day3 {
    @Test
    func p1() {
        #expect(day3.part1(input: """
xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))
""") == 161)
    }

    @Test
    func p2() {
        #expect(day3.part2(input: """
xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))
""") == 48)
    }
}

struct Day4 {
    let input = """
MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX
"""
    @Test
    func p1() {
        #expect(day4.part1(input: input) == 18)
    }

    @Test
    func p2() {
        #expect(day4.part2(input: input) == 9)
    }
}

struct Day5 {
    let input = """
47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47
"""
    @Test
    func p1() {
        #expect(day5.part1(input: input) == 143)
    }

    @Test
    func p2() {
        #expect(day5.part2(input: input) == 123)
    }
}

struct Day6 {
    let input = """
....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...
"""
    @Test
    func p1() {
        #expect(day6.part1(input: input) == 41)
    }

    @Test
    func p2() {
        #expect(day6.part2(input: input) == 6)
    }
}

struct Day7 {
    let input = """
190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20
"""
    @Test
    func p1() {
        #expect(day7.part1(input: input) == 3749)
    }

    @Test
    func p2() {
        #expect(day7.part2(input: input) == 11387)
    }
}

struct Day8 {
    let input = """
............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............
"""
    @Test
    func p1() {
        #expect(day8.part1(input: input) == 14)
    }

    @Test
    func p2() {
        #expect(day8.part2(input: input) == 34)
    }
}

struct Day9 {
    let input = """
2333133121414131402
"""
    @Test
    func p1() {
        #expect(day9.part1(input: input) == 1928)
    }

    @Test
    func p2() {
        #expect(day9.part2(input: input) == 2858)
    }
}

struct Day10 {
    let input = """
89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732
"""
    @Test
    func p1() {
        #expect(day10.part1(input: input) == 36)
    }

    @Test
    func p2() {
        #expect(day10.part2(input: input) == 81)
    }
}

struct Day11 {
    let input = """
125 17
"""
    @Test
    func p1() {
        #expect(day11.part1(input: input) == 55312)
    }

    @Test
    func p2() {
        #expect(day11.part2(input: input) == 65601038650482)
    }
}

struct Day12 {
    let input = """
RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE
"""
    @Test
    func p1() {
        #expect(day12.part1(input: input) == 1930)
    }

    @Test(arguments: [
        ("""
AAAA
BBCD
BBCC
EEEC
""", 80),
        ("""
OOOOO
OXOXO
OOOOO
OXOXO
OOOOO
""", 436),
        ("""
EEEEE
EXXXX
EEEEE
EXXXX
EEEEE
""", 236),
        ("""
AAAAAA
AAABBA
AAABBA
ABBAAA
ABBAAA
AAAAAA
""", 368),
        ("""
RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE
""", 1206),
    ])
    func p2(input: String, expected: Int) {
        #expect(day12.part2(input: input) == expected)
    }
}
