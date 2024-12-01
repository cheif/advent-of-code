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
