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
