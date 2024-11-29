import AOC2024
import Testing

@Suite
struct Day1 {
    @Test
    func p1() {
        #expect(day1.part1(input: "") == 0)
    }

    @Test
    func p2() {
        #expect(day1.part2(input: "") == 0)
    }
}
