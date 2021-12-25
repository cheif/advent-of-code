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

    func testDay19() throws {
        let input = """
--- scanner 0 ---
404,-588,-901
528,-643,409
-838,591,734
390,-675,-793
-537,-823,-458
-485,-357,347
-345,-311,381
-661,-816,-575
-876,649,763
-618,-824,-621
553,345,-567
474,580,667
-447,-329,318
-584,868,-557
544,-627,-890
564,392,-477
455,729,728
-892,524,684
-689,845,-530
423,-701,434
7,-33,-71
630,319,-379
443,580,662
-789,900,-551
459,-707,401

--- scanner 1 ---
686,422,578
605,423,415
515,917,-361
-336,658,858
95,138,22
-476,619,847
-340,-569,-846
567,-361,727
-460,603,-452
669,-402,600
729,430,532
-500,-761,534
-322,571,750
-466,-666,-811
-429,-592,574
-355,545,-477
703,-491,-529
-328,-685,520
413,935,-424
-391,539,-444
586,-435,557
-364,-763,-893
807,-499,-711
755,-354,-619
553,889,-390

--- scanner 2 ---
649,640,665
682,-795,504
-784,533,-524
-644,584,-595
-588,-843,648
-30,6,44
-674,560,763
500,723,-460
609,671,-379
-555,-800,653
-675,-892,-343
697,-426,-610
578,704,681
493,664,-388
-671,-858,530
-667,343,800
571,-461,-707
-138,-166,112
-889,563,-600
646,-828,498
640,759,510
-630,509,768
-681,-892,-333
673,-379,-804
-742,-814,-386
577,-820,562

--- scanner 3 ---
-589,542,597
605,-692,669
-500,565,-823
-660,373,557
-458,-679,-417
-488,449,543
-626,468,-788
338,-750,-386
528,-832,-391
562,-778,733
-938,-730,414
543,643,-506
-524,371,-870
407,773,750
-104,29,83
378,-903,-323
-778,-728,485
426,699,580
-438,-605,-362
-469,-447,-387
509,732,623
647,635,-688
-868,-804,481
614,-800,639
595,780,-596

--- scanner 4 ---
727,592,562
-293,-554,779
441,611,-461
-714,465,-776
-743,427,-804
-660,-479,-426
832,-632,460
927,-485,-438
408,393,-506
466,436,-512
110,16,151
-258,-428,682
-393,719,612
-211,-452,876
808,-476,-593
-575,615,604
-485,667,467
-680,325,-822
-627,-443,-432
872,-547,-609
833,512,582
807,604,487
839,-516,451
891,-625,532
-652,-548,-490
30,-46,-1
"""
        let (a, b) = day19(input)
        XCTAssertEqual(a, 79)
        XCTAssertEqual(b, 3621)
    }

    func testDay20() {
        let input = """
..#.#..#####.#.#.#.###.##.....###.##.#..###.####..#####..#....#..#..##..###..######.###...####..#..#####..##..#.#####...##.#.#..#.##..#.#......#.###.######.###.####...#.##.##..#..#..#####.....#.#....###..#.##......#.....#..#..#..##..#...##.######.####.####.#.#...#.......#..#.#.#...####.##.#......#..#...##.#.##..#...##.#.##..###.#......#.#.......#.#.#.####.###.##...#.....####.#..#..#.##.#....##..#.####....##...##..#...#......#.#.......#.......##..####..#...#.#.#...##..#.#..###..#####........#..####......#..#

#..#.
#....
##..#
..#..
..###
"""
        let (a, b) = day20(input)
        XCTAssertEqual(a, 35)
        XCTAssertEqual(b, 3351)
    }

    func testDay21() {
        let input = """
Player 1 starting position: 4
Player 2 starting position: 8
"""
        let (a, b) = day21(input)
        XCTAssertEqual(a, 739785)
        XCTAssertEqual(b, 444356092776315)
    }

    func testDay23() {
        let input = """
#############
#...........#
###B#C#B#D###
  #A#D#C#A#
  #########
"""
        let (a, b) = day23(input)
        XCTAssertEqual(a, 12521)
        XCTAssertEqual(b, 44169)
    }

    func testDay25() {
        let input = """
v...>>.vv>
.vv>>.vv..
>>.>v>...v
>>v>>.>.v.
v>v.vv.v..
>.>>..v...
.vv..>.>v.
v.v..>>v.v
....v..v.>
"""
        let (a, b) = day25(input)
        XCTAssertEqual(a, 58)
        XCTAssertEqual(b, 0)
    }
}
