@testable import AdventOfCode
import XCTest

final class AdventOfCodeTests: XCTestCase {
    func testDay1() throws {
        let input = """
199
200
208
210
200
207
240
269
260
263
"""
        let (a, b) = day1(input)
        XCTAssertEqual(a, 7)
        XCTAssertEqual(b, 5)
    }

    func testDay2() throws {
        let input = """
forward 5
down 5
forward 8
up 3
down 8
forward 2
"""
        let (a, b) = day2(input)
        XCTAssertEqual(a, 150)
        XCTAssertEqual(b, 900)
    }

    func testDay3() throws {
        let input = """
00100
11110
10110
10111
10101
01111
00111
11100
10000
11001
00010
01010
"""
        let (a, b) = day3(input)
        XCTAssertEqual(a, 198)
        XCTAssertEqual(b, 230)
    }

    func testDay4() throws {
        let input = """
7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

22 13 17 11  0
 8  2 23  4 24
21  9 14 16  7
 6 10  3 18  5
 1 12 20 15 19

 3 15  0  2 22
 9 18 13 17  5
19  8  7 25 23
20 11 10 24  4
14 21 16 12  6

14 21 17 24  4
10 16 15  9 19
18  8 23 26 20
22 11 13  6  5
 2  0 12  3  7
"""
        let (a, b) = day4(input)
        XCTAssertEqual(a, 4512)
        XCTAssertEqual(b, 1924)
    }

    func testDay5() throws {
        let input = """
0,9 -> 5,9
8,0 -> 0,8
9,4 -> 3,4
2,2 -> 2,1
7,0 -> 7,4
6,4 -> 2,0
0,9 -> 2,9
3,4 -> 1,4
0,0 -> 8,8
5,5 -> 8,2
"""
        let (a, b) = day5(input)
        XCTAssertEqual(a, 5)
        XCTAssertEqual(b, 12)
    }

    func testDay6() throws {
        let input = "3,4,3,1,2"
        let (a, b) = day6(input)
        XCTAssertEqual(a, 5934)
        XCTAssertEqual(b, 26984457539)
    }

    func testDay7() throws {
        let input = "16,1,2,0,4,2,7,1,2,14"
        let (a, b) = day7(input)
        XCTAssertEqual(a, 37)
        XCTAssertEqual(b, 168)
    }

    func testDay8() throws {
        let input = """
be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
"""
        let (a, b) = day8(input)
        XCTAssertEqual(a, 26)
        XCTAssertEqual(b, 61229)
    }

    func testDay9() throws {
        let input = """
2199943210
3987894921
9856789892
8767896789
9899965678
"""
        let (a, b) = day9(input)
        XCTAssertEqual(a, 15)
        XCTAssertEqual(b, 1134)
    }

    func testDay10() throws {
        let input = """
[({(<(())[]>[[{[]{<()<>>
[(()[<>])]({[<{<<[]>>(
{([(<{}[<>[]}>{[]{[(<()>
(((({<>}<{<{<>}{[]{[]{}
[[<[([]))<([[{}[[()]]]
[{[{({}]{}}([{[{{{}}([]
{<[[]]>}<{[{[{[]{()[[[]
[<(<(<(<{}))><([]([]()
<{([([[(<>()){}]>(<<{{
<{([{{}}[<[[[<>{}]]]>[]]
"""
        let (a, b) = day10(input)
        XCTAssertEqual(a, 26397)
        XCTAssertEqual(b, 288957)
    }

    func testDay11() throws {
        let input = """
5483143223
2745854711
5264556173
6141336146
6357385478
4167524645
2176841721
6882881134
4846848554
5283751526
"""
        let (a, b) = day11(input)
        XCTAssertEqual(a, 1656)
        XCTAssertEqual(b, 195)
    }

    func testDay12() throws {
        let input = """
start-A
start-b
A-c
A-b
b-d
A-end
b-end
"""
        let (a, b) = day12(input)
        XCTAssertEqual(a, 10)
        XCTAssertEqual(b, 36)

        let input2 = """
dc-end
HN-start
start-kj
dc-start
dc-HN
LN-dc
HN-end
kj-sa
kj-HN
kj-dc
"""
        let (a2, b2) = day12(input2)
        XCTAssertEqual(a2, 19)
        XCTAssertEqual(b2, 103)

        let input3 = """
fs-end
he-DX
fs-he
start-DX
pj-DX
end-zg
zg-sl
zg-pj
pj-he
RW-he
fs-DX
pj-RW
zg-RW
start-pj
he-WI
zg-he
pj-fs
start-RW
"""
        let (a3, b3) = day12(input3)
        XCTAssertEqual(a3, 226)
        XCTAssertEqual(b3, 3509)
    }

    func testDay13() throws {
        let input = """
6,10
0,14
9,10
0,3
10,4
4,11
6,0
6,12
4,1
0,13
10,12
3,4
3,0
8,4
1,10
2,14
8,10
9,0

fold along y=7
fold along x=5
"""
        let (a, b) = day13(input)
        XCTAssertEqual(a, 17)
        XCTAssertEqual(b, 0)
    }

    func testDay14() throws {
        let input = """
NNCB

CH -> B
HH -> N
CB -> H
NH -> C
HB -> C
HC -> B
HN -> C
NN -> C
BH -> H
NC -> B
NB -> B
BN -> B
BB -> N
BC -> B
CC -> N
CN -> C
"""
        let (a, b) = day14(input)
        XCTAssertEqual(a, 1588)
        XCTAssertEqual(b, 2188189693529)
    }

    func testDay15() throws {
        let input = """
1163751742
1381373672
2136511328
3694931569
7463417111
1319128137
1359912421
3125421639
1293138521
2311944581
"""
        let (a, b) = day15(input)
        XCTAssertEqual(a, 40)
        XCTAssertEqual(b, 315)
    }

    func testDay16() throws {
        XCTAssertEqual(day16("8A004A801A8002F478").0, 16)
        XCTAssertEqual(day16("620080001611562C8802118E34").0, 12)
        XCTAssertEqual(day16("C0015000016115A2E0802F182340").0, 23)
        XCTAssertEqual(day16("A0016C880162017C3686B18A3D4780").0, 31)

        XCTAssertEqual(day16("C200B40A82").1, 3)
        XCTAssertEqual(day16("04005AC33890").1, 54)
        XCTAssertEqual(day16("880086C3E88112").1, 7)
        XCTAssertEqual(day16("CE00C43D881120").1, 9)
        XCTAssertEqual(day16("D8005AC2A8F0").1, 1)
        XCTAssertEqual(day16("F600BC2D8F").1, 0)
        XCTAssertEqual(day16("9C005AC2F8F0").1, 0)
        XCTAssertEqual(day16("9C0141080250320F1802104A08").1, 1)
    }

    func testDay17() throws {
        let input = "target area: x=20..30, y=-10..-5"
        let (a, b) = day17(input)
        XCTAssertEqual(a, 45)
        XCTAssertEqual(b, 112)
    }

    func testDay18() throws {
        let smallerExample = """
[[[0,[4,5]],[0,0]],[[[4,5],[2,6]],[9,5]]]
[7,[[[3,7],[4,3]],[[6,3],[8,8]]]]
[[2,[[0,8],[3,4]]],[[[6,7],1],[7,[1,6]]]]
[[[[2,4],7],[6,[0,5]]],[[[6,8],[2,8]],[[2,1],[4,5]]]]
[7,[5,[[3,8],[1,4]]]]
[[2,[2,2]],[8,[8,1]]]
[2,9]
[1,[[[9,3],9],[[9,0],[0,7]]]]
[[[5,[7,4]],7],1]
[[[[4,2],2],6],[8,7]]
"""
        XCTAssertEqual(day18(smallerExample).0, 3488)
        let input = """
[[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
[[[5,[2,8]],4],[5,[[9,9],0]]]
[6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
[[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
[[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
[[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
[[[[5,4],[7,7]],8],[[8,3],8]]
[[9,3],[[9,9],[6,[4,9]]]]
[[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
[[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]
"""
        let (a, b) = day18(input)
        XCTAssertEqual(a, 4140)
        XCTAssertEqual(b, 3993)
    }
}
