import AOC2025
import Testing

@Suite
struct Day1 {
    @Test
    func p1() {
        #expect(
            day1.part1(
                input: """
                    L68
                    L30
                    R48
                    L5
                    R60
                    L55
                    L1
                    L99
                    R14
                    L82
                    """) == 3)
    }

    @Test
    func p2() {
        #expect(
            day1.part2(
                input: """
                    L68
                    L30
                    R48
                    L5
                    R60
                    L55
                    L1
                    L99
                    R14
                    L82
                    """) == 6)
    }
}
