import AOC2016
import Testing

@Suite
struct Day1 {
    @Test
    func part1() {
        #expect(day1.part1(input: """
R5, L5, R5, R3
""") == 12)
    }

    @Test
    func part2() {
        #expect(day1.part2(input: """
R8, R4, R4, R8
""") == 4)
    }
}
