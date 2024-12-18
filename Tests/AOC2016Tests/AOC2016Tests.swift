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

@Suite
struct Day2 {
    @Test
    func part1() {
        #expect(day2.part1(input: """
ULL
RRDDD
LURDL
UUUUD
""") == "1985")
    }

    @Test
    func part2() {
        #expect(day2.part2(input: """
ULL
RRDDD
LURDL
UUUUD
""") == "5DB3")
    }
}

@Suite
struct Day3 {
    @Test
    func part1() {
        #expect(day3.part1(input: """
5 10 25
""") == 0)
    }

    @Test
    func part2() {
        #expect(day3.part2(input: """
101 301 501
102 302 502
103 303 503
201 401 601
202 402 602
203 403 603
""") == 6)
    }
}

@Suite
struct Day4 {
    @Test
    func part1() {
        #expect(day4.part1(input: """
aaaaa-bbb-z-y-x-123[abxyz]
a-b-c-d-e-f-g-h-987[abcde]
not-a-real-room-404[oarel]
totally-real-room-200[decoy]
""") == 1514)
    }

    @Test
    func part2() {
        #expect(day4.part2(input: """
qzmt-zixmtkozy-ivhz-343
""") == 0)
    }
}

@Suite
struct Day5 {
    @Test
    func part1() {
        #expect(day5.part1(input: """
abc
""") == "18f47a30")
    }

    @Test
    func part2() {
        #expect(day5.part2(input: """
abc
""") == "05ace8e3")
    }
}

@Suite
struct Day6 {
    let input = """
eedadn
drvtee
eandsr
raavrd
atevrs
tsrnev
sdttsa
rasrtv
nssdts
ntnada
svetve
tesnvt
vntsnd
vrdear
dvrsen
enarar
"""
    @Test
    func part1() {
        #expect(day6.part1(input: input) == "easter")
    }

    @Test
    func part2() {
        #expect(day6.part2(input: input) == "advent")
    }
}

@Suite
struct Day7 {
    @Test
    func part1() {
        #expect(day7.part1(input: """
abba[mnop]qrst
abcd[bddb]xyyx
aaaa[qwer]tyui
ioxxoj[asdfgh]zxcvbn
""") == 2)
    }

    @Test
    func part2() {
        #expect(day7.part2(input: """
aba[bab]xyz
xyx[xyx]xyx
aaa[kek]eke
zazbz[bzb]cdb
""") == 3)
    }
}

@Suite
struct Day8 {
    @Test
    func part1() {
        #expect(day8.part1(input: """
rect 3x2
rotate column x=1 by 1
rotate row y=0 by 4
rotate column x=1 by 1
""") == 6)
    }

    @Test
    func part2() {
        #expect(day8.part2(input: """
""") == 0)
    }
}

@Suite
struct Day9 {
    @Test(arguments: [
        ("ADVENT", 6),
        ("A(1x5)BC", 7),
        ("X(8x2)(3x3)ABCY", 18),
    ])
    func part1(input: String, expected: Int) {
        #expect(day9.part1(input: input) == expected)
    }

    @Test(arguments: [
        ("(3x3)XYZ", 9),
        ("X(8x2)(3x3)ABCY", 20),
        ("(25x3)(3x3)ABC(2x3)XY(5x2)PQRSTX(18x9)(3x2)TWO(5x7)SEVEN", 445),
    ])
    func part2(input: String, expected: Int) {
        #expect(day9.part2(input: input) == expected)
    }
}

@Suite
struct Day10 {
    let input = """
value 5 goes to bot 2
bot 2 gives low to bot 1 and high to bot 0
value 3 goes to bot 1
bot 1 gives low to output 1 and high to bot 0
bot 0 gives low to output 2 and high to output 0
value 2 goes to bot 2
"""
    @Test
    func part1() {
        #expect(day10.part1(input: input) == 2)
    }

    @Test
    func part2() {
        #expect(day9.part2(input: input) == 203)
    }
}

@Suite
struct Day12 {
    let input = """
cpy 41 a
inc a
inc a
dec a
jnz a 2
dec a
"""
    @Test
    func part1() {
        #expect(day12.part1(input: input) == 42)
    }

    @Test
    func part2() {
        #expect(day12.part2(input: input) == 42)
    }
}

@Suite
struct Day13 {
    let input = """
10
"""
    @Test
    func part1() {
        #expect(day13.part1(input: input) == 11)
    }

    @Test
    func part2() {
        #expect(day13.part2(input: input) == 151)
    }
}

@Suite
struct Day14 {
    let input = """
abc
"""
    @Test
    func part1() {
        #expect(day14.part1(input: input) == 22728)
    }

    @Test
    func part2() {
        #expect(day14.part2(input: input) == 22551)
    }
}

@Suite
struct Day15 {
    let input = """
Disc #1 has 5 positions; at time=0, it is at position 4.
Disc #2 has 2 positions; at time=0, it is at position 1.
"""
    @Test
    func part1() {
        #expect(day15.part1(input: input) == 5)
    }

    @Test
    func part2() {
        #expect(day15.part2(input: input) == 85)
    }
}

@Suite
struct Day16 {
    let input = """
10000
"""
    @Test
    func part1() {
        #expect(day16.part1(input: input) == "01100")
    }

    @Test
    func part2() {
        #expect(day16.part2(input: input) == "")
    }
}

@Suite
struct Day17 {
    @Test(arguments: [
        ("ihgpwlah", "DDRRRD"),
        ("kglvqrro", "DDUDRLRRUDRD"),
        ("ulqzkmiv", "DRURDRUDDLLDLUURRDULRLDUUDDDRR"),
    ])
    func part1(input: String, expected: String) {
        #expect(day17.part1(input: input) == expected)
    }

    @Test(arguments: [
        ("ihgpwlah", "370"),
        ("kglvqrro", "492"),
        ("ulqzkmiv", "830"),
    ])
    func part2(input: String, expected: String) {
        #expect(day17.part2(input: input) == expected)
    }
}

@Suite
struct Day18 {
    @Test
    func part1() {
        #expect(day18.part1(input: """
.^^.^.^^^^
""") == 38)
    }

    @Test
    func part2() {
        #expect(day18.part2(input: """
.^^.^.^^^^
""") == 1935478)
    }
}

@Suite
struct Day19 {
    @Test
    func part1() {
        #expect(day19.part1(input: "5") == 3)
    }

    // Serialized so it's easier to debug
    @Test(.serialized, arguments: [
        ("5", 2),
        ("7", 5),
        ("11", 2),
        ("19", 11),
        ("1001", 272),
    ])
    func part2(input: String, expected: Int) {
        #expect(day19.part2(input: input) == expected)
    }
}

@Suite
struct Day20 {
    let input = """
5-8
0-2
4-7
"""
    @Test
    func part1() {
        #expect(day20.part1(input: input) == 3)
    }

    @Test
    func part2() {
        #expect(day20.part2(input: input) == 2)
    }
}

@Suite
struct Day21 {
    let input = """
swap position 4 with position 0
swap letter d with letter b
reverse positions 0 through 4
rotate left 1 step
move position 1 to position 4
move position 3 to position 0
rotate based on position of letter b
rotate based on position of letter d
"""
    @Test
    func part1() {
        #expect(day21.part1(input: input) == "decab")
    }

    @Test
    func part2() {
        #expect(day21.part2(input: input) == "deabc")
    }
}
