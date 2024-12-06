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
""") == "")
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
