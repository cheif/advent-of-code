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
