import Foundation
import Shared

func sNeighbours(adj: [Direction: Grid<Character>.Point]) -> [Grid<Character>.Point] {
    var neighbours: [Grid<Character>.Point] = []
    for dir in Direction.allCases {
        switch dir {
        case .down:
            neighbours += [adj[dir]].compactMap { $0 }.filter { ["L", "J", "|"].contains($0.val) }
        case .right:
            neighbours += [adj[dir]].compactMap { $0 }.filter { ["7", "J", "-"].contains($0.val) }
        case .left:
            neighbours += [adj[dir]].compactMap { $0 }.filter { ["L", "F", "-"].contains($0.val) }
        case .up:
            neighbours += [adj[dir]].compactMap { $0 }.filter { ["7", "F", "|"].contains($0.val) }
        }
    }
    neighbours = Array(Set(neighbours))
    assert(neighbours.count == 2)
    return neighbours
}

private extension Array {
    mutating func append(_ v: Element?) {
        if let v {
            self.append(v)
        }
    }
}

private extension Grid where V == Character {
    func candidates(nextTo point: Point) -> [Point] {
        let adj = self.neighbours(to: point)
        switch point.val {
        case "|": return [adj[.up]!, adj[.down]!]
        case "-": return [adj[.left]!, adj[.right]!]
        case "L": return [adj[.up]!, adj[.right]!]
        case "J": return [adj[.up]!, adj[.left]!]
        case "7": return [adj[.down]!, adj[.left]!]
        case "F": return [adj[.down]!, adj[.right]!]
        case "S": return sNeighbours(adj: adj)
        default: fatalError()
        }
    }

    func path(start: Point) -> [Point] {
        var paths = [[start]]
        while !paths.contains(where: { path in path.count > 1 && path.first == path.last }) {
            paths = paths.flatMap { path in
                let next = self
                    .candidates(nextTo: path.last!)
                    .filter { path.dropLast().last != $0 }
                if path.last?.val != "S" {
                    assert(next.count == 1)
                }
                return next.map { path + [$0] }
            }
            assert(paths.count == 2)
        }
        return paths[0]
    }

    func leftRight(of path: [Point]) -> (left: [Point], right: [Point]) {
        var left: [Grid<Character>.Point] = []
        var right: [Grid<Character>.Point] = []
        for (i, point) in path.enumerated() {
            let adj = self.neighbours(to: point)
            switch point.val {
            case "|":
                if path[i-1].y > point.y {
                    // Going up
                    left.append(adj[.left])
                    right.append(adj[.right])
                } else {
                    left.append(adj[.right])
                    right.append(adj[.left])
                }
            case "-":
                if path[i-1].x < point.x {
                    // Going right
                    left.append(adj[.up])
                    right.append(adj[.down])
                } else {
                    right.append(adj[.up])
                    left.append(adj[.down])
                }
            case "J":
                if path[i-1].x < point.x {
                    // Going up
                    right.append(adj[.down])
                    right.append(adj[.right])
                } else {
                    left.append(adj[.down])
                    left.append(adj[.right])
                }
            case "L":
                if path[i-1].x > point.x {
                    // Going up
                    left.append(adj[.down])
                    left.append(adj[.left])
                } else {
                    right.append(adj[.down])
                    right.append(adj[.left])
                }
            case "F":
                if path[i-1].y > point.y {
                    // Going right
                    left.append(adj[.up])
                    left.append(adj[.left])
                } else {
                    right.append(adj[.up])
                    right.append(adj[.left])
                }
            case "7":
                if path[i-1].y > point.y {
                    // Going left
                    right.append(adj[.up])
                    right.append(adj[.right])
                } else {
                    left.append(adj[.up])
                    left.append(adj[.right])
                }

            default:
                break
            }
        }

        return (
            left.filter { !path.contains($0) },
            right.filter { !path.contains($0) }
        )
    }
}

public let day10 = Solution(
    part1: { input in
        let grid = Grid(lines: input.split(whereSeparator: \.isNewline).map { $0.map { $0 } })
        let start = grid.data.first(where: { $0.val == "S" })!
        let path = grid.path(start: start)
        return path.count / 2
    },
    part2: { input in
        let grid = Grid(lines: input.split(whereSeparator: \.isNewline).map { $0.map { $0 } })
        let start = grid.data.first(where: { $0.val == "S" })!
        let path = grid.path(start: start)
        let (left, right) = grid.leftRight(of: path)
        let setLeft = Set(left)
        let setRight = Set(right)

        let innerSet: Set<Grid<Character>.Point>
        if setLeft.contains(where: { $0.x == 0 || $0.y == 0 }) {
            // Left touches border, right must be the inside
            innerSet = setRight
        } else {
            innerSet = setLeft
        }

        // Expand to contain all
        var expanded = innerSet
        while true {
            let new = expanded.flatMap { point in
                grid.neighbours(to: point).values
                    .filter { !path.contains($0) }
            }
            let count = expanded.count
            expanded.formUnion(new)
            if count == expanded.count {
                break
            }
        }

        // 237 is too low
        return expanded.count
    },
    testResult: (8, 10),
    testInput: """
..F7.
.FJ|.
SJ.L7
|F--J
LJ...
""",
    part2TestInput: """
FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJ7F7FJ-
L---JF-JLJ.||-FJLJJ7
|F|F-JF---7F7-L7L|7|
|FFJF7L7F-JF7|JL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L
""",
    input: """
F|J-F|.|.F-F-7-7F--|77F.7.77F|-L7-|7|-|-F-L7.7FJF-7-JF7.77-F.7F7.FLF7-FF-L7F--F-J-..J-FJ-FLF7.FF.-F7-|-.F7--77F---7-LF7FFL7.F7|7FJ-FL-.-FJ-F
-L7-FL7--77J|.7.LJFJFLL.F-F-7JLL7-|-|F|L-.L||||7LJ.LF||LJL|L7FF.F|L||.|7-LFFJ.F7L7FJ|.7.F7.||J-F--|J7LLJJL-|-LL.L-7LLJ7-JFLF---FJ|FJ.L77L|J|
LLF-7LJ77|.77FJ-JLL-|-LLJF.JJJ.F7L|7L7.FJ.F-7J|77F|--J7JFFJFLLL|7JF7F--J.||L7.L7FJ-7|-F.L-FJ|LLL-FF77FJL-.-JLLL7.F|.-L-7L7|J7|L|7.J-L-JJ.-FJ
.|F7L-L7J77JLJ.|7|FFL-7|7L7F|JFLJ.LJ|L-LJF|.|J||L|7-L77.F7J7|FLL--||7JF-|-7L-FJJL.L7JFLJ.|L7L-7FF|7|7F7FLF.|.FF.F7L||LLF-LJJ-7||L-7||7|J.|||
F7JJFF7LFF|-JFF-7FL7|-LLJJJFF7-L|FJ-JJFLF-F-L--J.|.|.L|77J.L7|-L.F|L77JFJ|-J|JLFL-7|7L-|.FL|F7L7F7-L-JL-F7FFF77F-F7-|-L|7-J7.LFJJFJF77FFJLLJ
FJ.|FLJ-7L-7|||FJ-||F7..||..|77FF7|FJ|L7|J..FFLL---F7-LJ|.|-J|.FF.L7||-J7|JL7|FLF-F|LJ-F-7JLJ|FJ||7|-F-FJ|F-JL77JL7F-7FLFJ|F77FJF|JL7.LJL7.7
F7-FL|F-7JFL-7FJLFFJFJ.-|F--|JJJLF-|.|.JJ-F7FJL|||FJJ-FFJ.|77L-F-F-JL-7LF777JFF7|---7FF|FJ7-FJ|FJL7F7J-L7|L--7|F-7L7.|7JL--|-L|.||FF|7JL-LF7
|J.FJL7.L77F|JJJF-JL|---|.-JL7J-7|FF-7..|.F77--.L77J|-7J|7JL7LLL7L---7|-||F7-||7|-LJFFFJ|F7FL7LJF7LJ|JFFJ|F--J||FJ7J.L77F|FL7.LJLFF-JL-F-J.J
L-7L7.|7.L-FJJJFL-FFJ7|.L7L|LJ.L-77|F7-F7FF|J-F|-|J.7|L---77|7.LF-7F7|L7|LJ|F7F7-F.|F-JFJ|L7-L7FJ|F-JF7L7|L--7LJL-7F77.L777.FF77LF.|FF7JF7|J
FF-JJ7FJF||L|||JF-L|FJ77.F77J-L7LJLF7JLFF7JL---JF7-F777LL|.7-F7.L7LJLJFJ|F-J|||L7J7FJF-JFJFJF-J|JLJ.L|L7|L--7L7F--J||F77F7F7-7|77F77--L-LF7|
FL7|.FL-J7J7-|7.|||.7F777J|LJ.LL7F-J|7LF7-F7-|JFJL-JL7J.LF7F.||7LL7F-7|FJ|F7||L7L-7L7|F7L7L7L7FJ.|...L7LJF--JL||F7J|LJL7|||||LJ--|J.-JL-J|.|
LJ-|-F7|L-J|7FJ-JFLF.|J7L-|F-7|FJ||FF7F|L7||F--L-7F--J.|J|LF-JL7JFLJFJ|L7|||||FJF-JFJLJL7L7L-JL7FF7FF7L-7L7F-7||||LL7F-J|||L7J|F|F7|.LL-LJ-7
|FF|F-7L7.LL||-|.-7LFJ-J.LLJLF77|F7-F7FJFJ||7.|LFJ|F-7F-7J.L-7FJF-7FJFJFJLJ|||L7L-7L-7F7L7|F---JFJL7|L-7|FJL7LJLJL7FJL7FJLJFJ7LL-.7LJ7-F-|7F
|--F-|LL|F--J7FF.L|F7-F-FJ.FL.F--JL7||L7|-|L7F77L7||FJL7|FLF-J|FJFJL7L7L--7||L-JF-JJ|LJL7||L7LF7L7FJ|F7LJ|F7L-7F--JL7FJL7F-JF7.|.L7FLL7JLJ7J
|FFJ||LLLLL7F|7LJJ|L--77J.F7.FL---7LJ|FJ|-L7||L7FJLJL77|L7-L-7|L7|F-JFJ7F-JLJF--JF7.F7F-JLJFJFJL-JL7LJ|F7LJ||FJL7F7FJL-7|L--J|7--|.-JLJ--F-7
|F--777F||.-LJ|J|.JJJJL|J..F7F7F7L|F-J|FJF7||L7LJF--7L7L7L7F7||FJ|L-7|F-JF7F-JF-7|L7||L-7F-JJL7F7F-JF7LJL7FJFJF-J|||F-7LJF7F-J|.|LJ-|L|FLJ7.
L|.LLJF|-|-L|.LJ-F-777F-7.-|||LJ|FJL7FJL-JLJL7|F7|F7L-JFL7LJLJLJFJF7||L--J|L-7L7||FJ||F-J|F7F7LJ|L-7||F7FJL7|FJ.FJLJL7|F-JLJF7F7JJ|.FF-|JLF.
|.F.LF7|.J7.F777L|.F7-JF--|||L-7|L-7LJF7F----JLJ||||F7F-7L-----7|J|||||F7FJF7|FJ||L7||L-7LJLJL7FJF-J||||L-7|||F7|F7F7|||FF-7||||JLF-7J||7FLF
F.F7-L-LL-7-L-J7FL7||7.|.F7||F7|L-7L7FJLJF7F7|FFJLJ||||FJF---7FJL7|||L-J||FJLJL7|L7LJL7FJF7F--JL7L77|||L-7||||||||LJLJLJFJFJ|LJL7.|F|F|LJJ-7
-7FJFL|FJ|L.JFL-L-F||LF7F|||||||F-JFJL7FFJLJ|F7L-7FJ|||L7|F-7LJF7LJ|L--7||L-7F7||FL7F-JL7|LJF--7L7L-J|L-7||LJLJLJL7.F7F7L7|LL7F-J7FLL-L7||--
.J|J|.LF-J|F7|J|J.L|L-J|FJLJ|||||F7L-7L7L7F-J|L7FJL7|||FJLJJL--JL7FJF--J||F-J|LJ|F7||.F-JL-7L-7|-L--7|FS||L7F--7F7L7||||-|L--JL-77F|JJ|L7L.|
--J-L7-|7.FJ7|.|77|L--7|L--7LJLJ|||F7|FJFJL-7|FJL7FJ|||L7F7F-7F--JL7L--7||L7FL-7||||L7L-7F7|F7|L7F--JLJ|||FJL-7LJL-J||||FJF-7F-7L-7.|.F.F-L-
FLL7FJF|-7F-L-J|L|F7F7||F-7L---7LJLJLJL7|F--J|L7FJL-JLJFJ||L7|L--7FJF-7||L7L--7|LJLJFJF7||LJ|LJFJL--7F7||LJF-7L-7F-7|LJ||FJJLJJL-7L7J||FLF-L
77FFJ.-|.|..LF7L.L|LJ|||L7L--7FL-7F-7F-J||.F7|FJL7F----J7||FJ||F7|L7L7LJ|L|F--JL--7FJFJLJL-7L-7||F7JLJ|LJF-J7L-7||FJL7FJ|L-7F7F7-L7L7J-J||FJ
.F-J.77LJLFL7-|-LJL-7LJL7L--7|F-7LJFJL7FJL7||||F-JL7F7F7FJ|L7|FJLJFJFJF7L-JL-7F-7FJL7L7F---JF7|L7||F77L-7L7F7F7LJ||F7|L-JF-J|LJL-7L-J.LL|7L7
FJ-FFFL|-7J|L-JF||LLL7F7L-7J|||FJF-JF7LJF-J|LJ|L--7|||||L7L7||L-7FJ.L7|L--7F-JL7|L-7L-JL7F--JLJFJ|||L---JFJ|LJ|F7|||LJF7FJF-JF-7FJ|LLL.FL--|
7.FFJ||J..F|FFJFF7-FLLJL-7|FJ||L7|F7||F7L7FL-7L7F-J|||||FJFJ||7FJL7F7LJF7-|L7.FJ|F-JF---JL----7|||||F---7|7|F7||||||F-J|L-JF7L7LJF7L|.F77F-J
|F7|L-7-LFF.J|-FJL-7F----J|L7||FJLJLJLJL7L7-FJFJL-7||||||FJFJL7L7FJ|L7L||FJFJFJFJL-7L---7F-7F7|L-J|LJF--JL7||LJ||||||F7L-7FJL-JF7||7L|7JFF-F
|L7L7F7-F-.F|FF|F-7|L7F7F7L7|||L7JF7F7F7L7L7L7|F--J||||||L7L7FJFJL7|FJFJ|L7L7L7L7F-JF7F-JL7||||F--JF7L-7F7LJL7FJLJ|||||F7LJF7.FJLJ|-7||FFJFF
FL7|FJJF|.|LJJJLJL|L7LJLJL7LJ||FJFJ||||L-JFJFJ|L--7||||||FJFJL7L7FJ|L7|FJFL7|FJFJL7FJLJFF-JLJ||L-7FJL7.LJL7F-J|F--J|LJLJ|F-JL7L7F-J7L7.-77||
|7FJ7.F-J7|7-|.|.FL7L-----JF7LJL7|FJ||L--7L7|FJF77|||LJ||L7|F-JL|L7L7LJL-7FJLJFJF-J|JJF7L---7||F-JL-7|F7F7||F7|L--7|F---J|F--JFJL-77J.L-|F-J
7-|.F-7--F-77|7FF7|L-------JL--7|||L||F7FJFJ||F||FJ||F-JL7LJ|F-7L7L7L7F--JL--7L7L-7L7FJL7F7FJLJ|F7F7|||||||||||F-7LJL-7F7|L-7FJF-7L7.F7F-7J|
|FJF|L|7L|FJ-JFFJ|F7F-7LF7F----J|||FJ|||L7|FJL7||L7|||FF7L-7||FJ7L7|J|L-7F7F7|FJF7|FJL7FJ||L7F-J|||||||||||LJLJL7|F7F7LJLJF7||FJ-|FJ-F7J7.FJ
LJLLJ7LFFJ|JFFFJFJ||L7|FJ|L----7|||L7||L7|||F7||L7|||L7||F7|||L7F7|L7|F-J|LJ|||FJ||L7FJ|FJ|FJL7FJ||||||||||F7F7FJ||LJ|F---J|LJL-7||F77J.FFFJ
||.L|L.LL7||FFL7|J||FJ|L7|F--7FJLJL7||L7|||||LJL7||||FJ||||||L7||||FJ||F7L-7||||FJ|FJL7|L7||F-JL7||||||||LJ|||||FJL-7LJF--7L----JLJ||F7FJJJ|
L|-F|F7FF||F-7FJL7||L7|FJ|L-7|L7F-7LJ|FJ||LJL7F7|LJ|||FJ|||||FJ||||L7|||L7FJ||LJ|FJL7FJ|FJ|||F7FJ||LJ||||F-JLJ||L7F7L-7L-7L--7LF7F-JLJL7|JFF
||F|L-JFFJ||FJL-7LJL-J|L7|F-JL-JL7L7||L7|L--7|||L-7|||||LJLJ||FJ|||FJ|||FJ|||L-7||F-JL7|L7LJ||||LLJ|FJ|||L---7|L7||L--JF7|F--JFJLJF----J-.|J
L7JJJ|-FL7|||F77L---7FJFJ|L-7F---JLL7|FJ|F7FJ||L7FJ|||L----7||L7|LJ|FJLJL7L7|F-JLJL7F7||FJF-J||L---7L-JLJF---JL-JLJF---JLJL-7JL7F-J-F-7|J.|7
.L7.7JLF7||||||F-7F-JL-JFJF7||F--7FFJ||7|||L7LJFJL7|||F--7FJLJ.|L7FJL7F--JFJ||.F---J|||||FJF7||F---JLF7F7L-7F7F7F7J|F-7F7F-7L7F|L---JFJ7.|.|
FLF-L-FJLJ|||||L7||F---7L-J|LJL-7L-J7LJFJ|L7L-7L7FJLJ|L-7LJJF--JFJ|F-J|F7FJLLJFJF--7|LJ||L7|LJ||F----JLJ|F7LJ||LJL-JL7|||L7L7L-JF7F7FJ7.FF77
F7.FL.L--7||LJL-J|LJF-7L-7FJF7F7L-----7L7|LL-7|J||F7FJF7||F-JF-7|FJ|F-J||L---7L7|F-J|F7||FJL-7LJ|F7F7F-7LJL--J|F--7F7|LJL-JFJF7FJLJ|L7F7FJ.L
77F7J7|F-J|L7F--7|F7L7|F-JL7|||L------J|LJF7FJ|FJLJ|L7||L7L7FJFJ|L7||F7||F-7FJFJ|L-7LJ|LJL7F7|F7LJLJLJFJF7F7F-JL-7||||F---7L7||L--7L7LJ|J-FJ
F--F-FFJF7L7LJF-JLJL-J|L--7|||L----------7||L7|L-7FJL||L7L7|L7L7L7LJLJ|||L7|L7L7L7JL7FJF--J|LJ|L7FF7F7L-JLJ|L7F-7|LJ|LJF7FJFJ||F-7L7L--J-7|.
L--F--JFJL7L-7L7F7F7F7L---JLJL7F--7F-----J|L-JL-7||-FJL7|FJ|FJFJFJF---J|L7|L-JF|FJF-JL7L7F7L-7L7L-JLJL7JF-7L7|L7LJF7L--JLJJL7||L7L7L-7J|FL-J
.L.L---JF7L-7|FJ|||LJL7F-7F--7|L-7|L-----7L--7F-J||FJF7|LJJLJLL7L7|F7F7L7||F---JL7L7F-J7|||F7|FJF7F7F7L7L7L-J|FJF7||F7F7F7||LJL-JJL-7|JF|JLJ
F.L|7-F-J|F-JLJFJ||F--J|-LJF-J|F-JL------JF7F|L-7LJL7|LJ.F--7F7L7|LJ|||FJLJ|F--7FJFJ|F-7||||LJL-JLJLJL7L7L---JL-JLJLJLJLJL7F7F-7L7.|LJJ-FJ.|
.FFLF7L-7|L---7|.LJ|F--JF7LL-7|L------7F-7|L7|F7L-7FJL-7FJF-J||.LJF-J|LJF7LLJF-JL7L7LJFJLJ|L7F---7F7F7L7L-7F---------7F7F7LJLJFJ-|-||F--JJ7.
-.FFJL--J|LF--J|F-7||F--J|F--JL-------JL7LJFJLJL-7|L7F7LJFJF7|L---JF7L7J|L---JF-7L7L7FJF--JFJL7F7LJ||L-JF7LJF------7FJ|LJL-7F7L--7J|FL|-7L77
LFFL-7F-7L-JF--JL7LJ|L--7|L7F-7F7F-7F7F-JF-JF7F77LJFJ||F-JL||L---7FJL7L7L---7FJFL7|FJL7L--7L7|||L-7|L---J|F7|F-----JL7L-7F7LJL---J-F7FJ7L-J7
.-JLLLJ.L7F-JF7F7L-7|F--JL-JL7|||L7LJLJF7L7J|||L--7|FJ|L---JL7F--JL-7L7L-7F-JL7F7|||F7L--7L7L7|L7FJL7LF7-LJLJL7F---7FJF7LJL-------7-F7F7LL7.
|J|J7FJ7J||F-JLJ|F7LJL7F-----JLJL7|F---J|FJFJLJF--JLJF|F7F7F7|L-7F7FJL|F-JL-7FJ||LJLJ|F7FJ7L7|L7|L-7L-JL---7F7LJF--JL-JL----7F7F-7|J|LJJ|.||
|F-7FFJFFLJL-7F7||||F7LJF--7F7F7.LJL---7|L-JF7FJF7F---J|||||||JFJ|LJ.FJL7F--JL-JL7LF7||||F7FJL7LJF-JF7F7F7-LJL-7L----7F----7LJLJ.LJ.FJ|FF-F-
L-|-FJ-|J-F77LJ||||FJL--JF7LJLJL-------J|F7FJLJFJ||F-7FJLJ||||FJFJF--JF7|L7F--7F7|FJLJ||||LJF7L7FJF7|||||L----7L----7LJF7F-JF-7F7-F-7F77L7L|
L-J.LJF-F-JL7LFJLJ|L--7F-J|F-7F--------7|||L--7|FJ||FJL--7LJ||L7|FJF7FJ||FJ|F-J||||F7FJLJL-7||FJL7|LJ||LJF-7F-JF---7L7FJLJF7L7LJL7|FJF-7J|.|
.L|7-J-LL7F7L-JF-7L7F7LJF7LJFJ|F-------J|||F-7LJ|JLJ|F-7FJ-F||FJ|L7||L7|||FJL7FJLJ||LJF----J|LJF-J|F-J|F-JFLJF7|F--JFJ|F7FJ|FJF--J||7|FJ-||7
|LL--7|F-J|L7F7|JL7LJL--JL--JFJL7F-----7|||L7L-7L7F7LJL||7FFJ|L-J-LJ|FJLJLJFFJL--7||F7L--7F7|F7L-7|L--JL-----JLJL--7L7||LJFJL7|F--JL-JL77|L7
|.F|L-FL-7|7LJ||F-JF---------J7LLJ7F---JLJ|FJF7L7LJL-7FJ|F7L7|L|F---JL7F----JF7F7|||||F--J|LJ|L-7LJF---------------JJ|||F-JF-JLJF----7FJ7FJ|
F7|-.J..FJ|F--J|L-7|F7F--7F7F77-F7FJF----7|L-JL7|F---JL7LJ|FJL-7|F7F7FJL-7F-7|||||||||L-7FJF-JF7L--JF-------7F7F7F7F7LJ||F7|F7F7L---7LJLLJL|
LLJLF.LFL-JL-7FJF7LJ||L-7||||L7FJ|L7|F---JL-7F-JLJ|F-7L|F-J|F7FJ||LJLJF7FJL7|||||||||L--JL7L-7|L---7|F------J|||||||L--J||||||||F7F-J..L|-7J
FJ7-|7.J|L-LLLJFJL--JL--JLJ|L7|L7L7LJL-----7|L-----JFJ.LJ7FJ|LJ-LJF|FFJLJF-J||||LJLJ|F-7F7|F-JL7F-7LJL-----7FJLJLJLJF--7LJLJ|LJLJ|L---77J7|.
-J|-|J7L7FFFFF7L----7F7F7F7L-JL-JFJF--7F---J|F7F---7L-7.|FL-JJ..|JJ--L-7FJ7LLJLJF---J|FJ||||F7FJL7L7JF7F7F-JL-7F---7L-7L---7L---7|F---JF--L-
|J|.F-F-J7-F-JL----7LJLJLJL-7F7F7L-JF7LJF7F7LJ|L-7FJF-J7FLLJ|.L-|F|LFLLLJ.|.L|JF|F7F7||FJ||||||F7L7L-JLJLJF7LFJL--7|F-JLF-7L----J||||-L7L-JJ
.FJFL7F..|JL-7F-7F7L7-F-----J|LJL7F-JL--JLJL-7L7FJL-JF7-FJJFF7.-F7F.F7|-L7J--J.-LJLJLJ|L7LJLJLJ|L-JF-7F---JL-JF-7FJLJ-F7|FJFF7|F7LJ7JF-|.JJ7
F7.-LLJ7F-.|J||FJ|L7L-JF-7F--JLF-J|F-----7F-7L7LJF7F7||F77.FF7L.L|.7.|-.L|JFL7F..LF7F7L-JF--7F7L--7|LLJF7F-7F-JLLJ-|F7|LJL-7|L-JL-777|LL7J.|
JJ-JLJ-J-J-F.LJL7L7L7F7L7LJJF7FJF-JL-7F-7LJ-L7L--JLJLJLJ|--|.7.7J|FJ-||FF|LLF7J-|-||||-F7L-7|||F--J|F7FJLJFJL---7F7FJ||F---J|F--7FJ-FLF7|.LL
..|.LJ7.L|J.FFF7L-J7LJL-JF7FJLJFJF---J|FJJF7.L--7F7F7F-7|J|L7|7L||JLF--F|-7FJ|F-F-JLJL7||F7||||L---J||L7F7L7F7F7LJ||FJ|L---7|L-7LJJ.||||L|J|
---77--J.|.FF-JL--7F---7FJLJF7FJFL----JL--JL---7LJLJLJJLJFFJF777-||.|L-|JF|7L7JF|F---7LJLJLJLJL7F7F-JL-J||JLJLJ|F7LJL7|F7F-J|F7L-7JF7F--7J|L
|7LL7FL|F7J|L----7|L--7LJF-7||L7F--------------JF7LF7.L|--7.-J|L7|FL-7.|.F-JJF.FJ|F--JF-------7||LJF7F7FJL-7F7FJ||F-7LJ|LJF7||L-7|7L--7.|L|J
LL7F|JFFJJLJJFF--JL-7FJF7|FJ|L7|L----7F7F7F--7F7|L-JL77|7FF7JFF|L-7J.L77F-7JF|7L7|L7F7|F------JLJF-JLJLJ-F7LJ|L7|LJFJF7L-7|LJL-7LJ77|L|F7-LF
-.F7|LFFJLL|FFL---7FJL7||||FJJLJF7F--J|LJLJF7LJ||F---JF--7JL7|L7JLL7F||LJ-JFLJF-JL7LJLJL--7F-----J-F7F7F7||F7L7|L-7L7|L-7LJF---JF-7-JFLLJJ|.
L7LLJF|L77F.F-----J|F-J|LJLJF7F7||L---JF-7FJL--J||F---JF-J77L-7LF.J-7--7-JF-7LL--7|F--7F--J|F------JLJLJLJLJL-JL--JJ||F-JF-JF7F7|FJ.F-J|.-7|
L7.J-LFJFJJ-L-----7|L7FJF---JLJLJL-----JJ|L----7|||F7F-JF-7J7||7.F.LL.L|-.J.J-JJ|LJL-7|L---JL----------7F7F-7F----7FJ||F7L--JLJ||L7F7|L7.F-7
|LJJ||L-7JFFFF----JL-J|L|F7F7F--7F-7F---7|F----J|LJ|LJF7|FJ7L7L-|J..|-|F.|-FJ.|FLJF--J|F-7F------------J||L7LJF-7FJL7||||F7F---J|FJ||7F|J--7
JLJ-77F||FFF7L-----7F7|FJ|||||F-JL7LJF--J||F7F-7|F-JF7|LJL-7-F-|F-L.||LF-F7.|FLFJ|L7F7LJFJL-------------JL-JF-J.LJJFJ|||||||F---JL-JL77J..--
L-|.-J-F-F-JL7F----J|||L7|||LJL-7FJF7L--7|LJ|L7LJL--JLJF7F7L7LFJ77JF7J|.L||-F-JJ.|-LJL-7|F7F7|F--------77F-7|F7F7F7L-JLJLJ|LJF-------JF777L|
F.F7FJLL.L--7|L-7F--J||JLJLJF7F-J|FJL---J|F7L-JF------7|LJL-J7|JF7.F77FFFJL-77|F-77LF--JLJLJL-JF----7F7L-JFJLJLJLJL7F77F-7|F7L--------JL77-F
FLJFJFF.F-7-||7FJL7F-J|F---7||L-7|L-----7|||F-7L7F7F-7|L---7.-J.JJFFF7F7L--7L-77F--|L---7F7F---JF7F7||L7F7L----7F-7LJL-JFJLJ|F---7F7F-7FJJ-7
7|||L-F-L7|FJL-JF7|L--JL--7LJL77LJF-----JLJLJJL7LJLJFJL7F7FJ7..LL--FJLJ|7FFJF-JJF|.FF7F7LJ||F7F-JLJLJ|L||L----7LJ-|F----JF7FJL--7LJLJFJ|7.FF
L-J|..LF7||L---7|LJF--7LF7L--7|F77L7F7F7F7F7F7LL----JF7LJ||JF-LJ7FLL--7|F7L7L7JFF7FFJLJL77LJ||L--7F--JFJ|F----JF-7|L--7F7|||F7F-JJLJJL-J-FLJ
|-LL-LF|LJL----J|F7L-7L-JL-7L||||F7LJLJLJ||LJL-------J||.LJ.|F|J7F-F7FJLJL7L7L7FJ|FJF7F7L7LFJL-7|LJF--JFJL-7F--JFJ|F-7LJLJ|LJ|L---7J7.JJFL-7
-F-J.F|L-7F-----J||F7L----7L-JLJLJL--7F--J|F---7F7F7F7L-77-F77J-F--J|L7F-7L7|FJL7|L7|LJL7L7L7F-JF7-L-7FJF--J|F-7L7|L7|F7F7L-7|F--7|77.L-J|7|
FL|7F7J7LLJ-F----J|||F-7F7|F7F7F-7F-7||F--JL-7FJ|LJLJL7FJ7-FF7|FL7F-J7LJ|L7LJL-7|L7|L7F7L7|FJL--JL--7LJJL7F-JL7L-JL-J|||||F-J|L-7LJLFJ7FJLLJ
J-JFLJ-|-F-7|F--7FJ||L7||LJ||||L7LJFJLJ|F--7FJL7L7F--7|L---7||-F7||F----7LL---7LJFJL7|||J||L-7F----7|F7F7LJF7FJF--7F7LJLJLJF7L-7|7.FJ-FF7JLF
|L|L7LF|7L7LJ|F-JL-JL-J|L7FJLJL-JF7L---JL-7|L-7L7LJF-J|F---J||7|LJ|L-7F-JFF7F-JF7|F7LJ||FJ|F-JL7F--JLJ|||F7||L-JF-J||F7F---JL-7||-77FF|J|.FF
J.L--JL-F-JF7|L7F7F7F-7L-JL7F-7F7||F-7F---JL--JLL-7L-7LJF7..|L7L-7L-7|L7F-J||F7|LJ|L7FJLJFJL---JL----7||LJLJL--7L7F|LJLJF-----JLJ||J|---L-FJ
LJJ-|JJLL-7|LJ-LJLJLJFJF7F7|L7||||LJFJL----7F7F--7L--JF7||F-JFJF7L7FJ|FJL-7|LJ||F7|FJL7F7L--7F7.F----J|L-----7-L-JFJF7F7L------7-F|7..L7--JJ
7JF-|.FF-7LJ|F-------JFJ||||J||||L-7L-7F---J|LJF7L--7FJLJ|L-7L7||F||FJL7F7|L7FJ|||||7JLJL-7FJ||FJF-7F7L------JF--7|FJLJL-7F-7F-J-F-777.|.|7.
-JL.|F-|FJF7FJF-----7FJ|LJLJFJLJL-7L7FJ|FF--JF7|L---JL7F-JF7L7|||FJ||F-J|LJFJL7LJLJL7F7F--JL7||L7L7LJ|F--7F7F7L7FJ||F-7F7LJJLJF--JFJ-J7L|.L-
|-J7|77||J||L-JF----J|F-----JF7F-7L-JL-JFJF--J|L---7F7|L7FJ|FJ|||L7||||FJF-JF7L-7F--J||L-7F7LJL7L-JF7LJF7LJLJL-JL7|LJFJ|L--7F7|F--JJ-|77J.|7
F.|F7-FJL-J|FF7L-7F7FJ|F7F7F-J|L7L------JFJF7LL----J|LJFJ|FJL7LJ|FJLJL7L7|F7||F-JL7F7|L-7LJL--7L-7FJL--JL--7F----J|F-JFJF--J|LJL-7J7J|LL7FF|
F--7JFJF7F7L-JL--J||L7LJLJLJF7L-JF------7L-JL---7F-7|F-JFJ|F7L-7|L-7F-JFJ|||||L7F7LJ|L-7L-7F-7L7FJL---7F--7|L-----JL--JFJF--JF7F-J.||F.FFL7J
|.FF-L7|||L7F7F---JL7L7F----JL--7|F--7F7L-------J|FJ|L-7L7LJ|F7|L7FJ|F7L7LJ||L7|||F7|JFJF-JL7L-JL-----J|F-JL7F7F--7F---JF|F--JLJ7.F7F7.FFL|7
.|7.|FLJLJ-||||F--7FJFJ|F---7F-7LJ|F-J||F-7F-7F7J||FJF7|FJF7||LJFJL7||L7L7FJ|FJLJ|||L-JFJ|F7L7F7F----7FJL--7LJLJF7LJF----JL---7F--JLJ|FJJ|.|
LLF7.LJ.FF7LJLJL-7|L-JFLJF7FJ|FJF-JL--JLJFJL7LJL7||L7|LJ|FJLJL-7|F-JLJFJFJ|7||-F7||L7F7L7FJ|FJ|||FF77LJF---J-F7L|L7FJF-7F-----J|F----JJ|7FF-
..L-J|--FJ|F77F--JL---77FJ|L7|L7L7F-7F7F-JF7L7F-J||-|L7L|||FF7|||L7F--J.L7L7||FJ|LJF||L-JL7|L7|||FJL-7.|F7F7FJL7|FJ|FJLLJF--7F-J|F7F7|J|FF||
-L.|-F7-L7LJL7L7F7F7F7L7L7L7LJ7L-JL7LJ|L7F||FJL-7|L7|FJFJL7FJ|FJ|FJL-7F7FJFJ||L7L7FFJL7F7F|L7LJ||L-7FJFJ|LJLJF-J|L-JL-7LFJF-J|F7|||||F7F77|7
|J.L.|L-7L--7L-J|||LJL7L-JFJJF7F--7L-7L7L-J||F--J|FJ||-L7FJL7LJFJL7F-J|||FJFJL7L7L7L-7||L7L7|F7LJF-JL-JFJF--7L7FJF7F-7L-JFJF7||LJ|LJLJLJL--7
-F7FFL-7L---JF7FJLJF-7L7F7|F7||L-7|F-J-L---J|L-7FJL7|L7FJ|F7L-7L-7||F7||||FJF-J|L7|F-JLJFJFJ||L-7|F7F7FJ-L-7|FJ|FJLJ-L7F7L7|LJ|F7|F----7F7FJ
JLL7J7LL7F--7||L7F7L7|-LJ|LJLJL7-|LJF7JF----JF-J|F-JL7||FJ||F-JF-J|||||||||FJF7F7||L-7F-JJL7||F-JLJ||LJF7F-JLJJ|L----7||L-J|F-J|LJ||F-7||LJJ
LF.JF7.F||F-J||FJ|L-JL---JF--7FJFJF-JL7L7F---JF-JL7F7||||J||L-7|F7|||LJ||LJL7|||||L-7|L7F7FJLJ|F--7LJF-JLJ.F7LFJF----J|L7F7||F7|F-JFJFJ||JJ7
|JFJ-|7FLJL--JLJJL---7F7F-J.FJL-JFJF-7L-J|F7F-JF--J|||||L7||F7|||||LJF7|L-7FJ||||L-7LJFJ|||F--JL7FJF7L-----JL7L7|F7F77L7LJLJLJLJL--JFJ7LJ|.J
-77|F-7FLF----7F---7JLJLJ-F7L----JFJLL7F7LJ|L-7L7F7|LJ|L7|||||||||L7FJLJF-J|FJLJ|F7L7FJJ|||L7F7FJ|FJL7F-7F-7FJFJLJLJ|F7L--7F--------JF7.FJJ|
L--FJ-F|-L7F-7|L-7FJF-7F7FJL77F--7L--7LJL--JF7|FJ||L-7L7|||||LJ|||L||F7|L-7|L-7FJ||FJL-7|LJFJ||L7|L-7|L7LJ|LJ7|F----J||F7FLJF----7F--JL77||F
L7|||J|||LLJJ||JFJL7L7LJLJF7L-JF7L---JF-7F--J||L7|L-7L7|||||L-7||L7|LJL7F7||F7|L-J||F--JL-7L7|L-J|F7||FJF7F---JL-----JLJL---JF---J|F7F-J--77
|-F7-7|7-7LF-JL-JF7|FJF7F-JL---JL--7F7L7|L--7||FJ|F-J.||||||F7||L7|L-7FJ|||||||F--J||F7-F7|FJ|F--J||||L-JLJF7F7F---7F7F-7F--7|F7FFJ|LJJJ|||L
--LJL7LJJ-.L-----J||L7|||F-7F7F----J||FJL7F-J||L7||F7FJ||||||||L7|L7FJL7||||||||F7FJLJ|FJ|||FJL7F7|||L7F7F-J|||L7F7LJLJ||L-7|LJL-JFJF7|.F7||
.-J7.L-JJJ.F7.F7F7||FJ|||L7LJLJF---7|||F-JL7FJL7LJ||||.||||LJLJFJ|FJL77||LJ||||LJ|L-7LLJFJ|LJF7|||||L7||||F7LJL7LJL----7|F-JL7F7F7L-JL-7F777
7.FJ7F.|.LFJL-JLJLJ|L-JLJ7L-7F-J|F-J||||F7FJ|F7L-7|||L7|||L--77L-JL7FJFJL-7LJ||F-JF-JF7FJFJF7|LJ|||L7||||LJ|F-7L7F7F7F7||L--7||||L7F---J||7|
FJ-L|----FL----7F-7L--7F-7F-J|F--JF7|LJ|||L7LJL7FJ||L7|LJL7F-JF7F7-||J|F--JF-J||F7L7FJLJFJFJLJF7||L7||LJ|F7LJFJ-||LJ||||L-7FJLJ|L7|L----J|-J
|LF7L7LJ.LF---7LJ|L--7LJFJ|F7||F--J|L-7|||FJF--J|FJ|FJL-7FJL-7|LJL-J|FJL--7|F7||||FJL7F7|7|F7FJ|||FJLJF7|||F-JF7||F7LJ||F-JL--7L-J|F-7F--J.|
F|.LJ|.FFL|F-7L--77F-JF7L-J|LJLJF--JF7|LJ||FJF7FJ|FJL7F-J|F7FJL-7F7FJ|F7F7|LJLJ|||L-7|||L7LJLJJ||||F77|LJ||L--J||LJL7JLJL-7F--JF77||||L--7-F
J.FL-F7F77||FJF-7L-JF-JL7F7|7F7FJF7FJLJF-J|L7||L7|L-7|L7|||LJF--J||L7||LJ|L7F--J||F7|||L7L7|F--J||LJL7|F7||F--7|L7F7L7F-7FJL---JL7||FJF7FJ7|
|-F7L||7LLLJL7|L|F-7|F--J|LJFJLJFJ||F-7|F7|FJ||FJ|F7|L7L7|L7J|F-7||FJ|L-7|FJL--7|||LJLJ-L7L7L--7||F--JLJLJ|L7FJL7||L7LJFJL7F-----JLJL7|LJ.F|
|FJJ||JL.LJFFJ|FJ|FJ|L---JF7L7F7L7|LJFJLJ||L-J||FJ|LJFL7|L7L7LJFJ||L7|F7|LJF7F-J||L-7F7F7|FJF--J||L--7-F--JFJL7FJ|L7|F-JF7|L------7|J|L-7FFJ
7.FL|JLL|.LLL7|L7|L-JF----JL-J|L7||F7L-7-LJF7FJ|L7L---7||LL7L-7|FJ|FJ||LJFFJLJF7||F7||LJLJ|FJF-7|L-7FJFJF-7L7FJ|7|FJ|L--J||F7F7F--J-.|F-JJ-7
F-7|L-J7|77|L||FJL7F-JF7F-7F-7L7LJ|||F7L--7|LJFJFJF-7FJ|L7L|F7|LJ-||JLJF-7L--7|LJLJ||L7F7FJ|FJF|L-7LJLL-JFJFJL7L7LJ7L-7F7|||LJ||F7||-|||L|||
|J.F-|-FJ-|JJLJL7FJ|F7||||||FJFJF7||LJ|F7FJ|F7L7L7|L|L7L7|FJ|||F--JL-7FJFJF--JL--7FJL7||||FJ|F-JF7L-----7L7|F7L7L----7|||||L-7|LJ|-JFLJJ-777
F--|-|-|J-|.LJF|LJFJ|LJ||FJ|L-JFJLJL-7|||L7||L7|7||FJFJ||||FJ||L7F7F7LJFJ-L---7F-JL7FJLJ|||FJL-7|L-7F7F7|FJ||L-JF--7FJLJ||L7FJ|F-JJLJLLL-|JJ
LJ7|-L.L|FJ|.|FFF-JFJF7LJ|FJF--JF7F-7|||L-J||FJ|FJ||FJFFJ||L7||FJ||||F7L--7F--JL-7FJL--7||||F-7|L-7LJLJLJL-J|F7FJF7LJLF7LJ7|L7||JL.|7JLJ||J7
L-J|FLL.||7JF|7J|F7|FJL7L||FJF7FJ||FJ||L--7||L7||FJ||F-JFJL7|||L7|||LJ|F--J|F-7F7|L7F--J||LJL7LJF7L---7.F7F-J||L-JL---JL7.-L-JLJJL-L|..FLF7F
L-L|-F--L-7-|J|-LJ||L-7L-J|L7|||FJ|L7||F7FJ||7|||L7||L7FJF-J|||FJ|||F-JL--7|L7||||FJL-7FJL7J.|F7||F7F7|FJLJF7|L7F-7F----J7|F|JJ|.L7-J-F-JL|J
..|.||JJ|LL-|.|F|7LJLL|F-7L7LJ||L7L7LJLJ||FJ|FJ|L7|||FJL7L--J|||FJ||L-7F-7||FJLJ||L7F7||F7|F-J|||LJ||LJL7F7||L7|L7|L-7JF---7J7FFJ-F7JF7LF7J|
F|-|-F7.F.LFJFJ.|FFL7FLJ.L7L-7||LL7L---7||L7||FJ.||||L7FJF---J|||FJL7FJL7|||L-7FJ|FJ||||||||F7||L-7LJF--J|||L7||FJ|F7L-JF7FJJFLJ7.J7FJJ.L|.|
.L7|FL7-|JFF.JF---7F-LF---JF7|||F-JF7F7|||7||||F7|||L7||7L7F-7|||L--JL7FJLJ|F7||FJ|FJ||||LJ|||||F7L-7L7F7||||LJ|L7||L7F7|LJJFL||F.LJJL7|L|--
L|FL77J.LJ7|7FJ7.F-7JJL-7F7||||||F7|||||||FJ||LJ||||FJLJ-L||FJ|LJF7|F7|L-7FJ|||||FJL7||||F7||LJLJ|F-J7||||||F--JFJ|L7|||L7|.F-FFJ-F-7L|J7.F.
.7J|LLFJF7-L|-|-F7J.LFJ.LJ||||LJLJ||||||||L7|L7FJ|||L-7|J|||L7|F-JL-JLJF7||FJ||LJL7FJ|||||LJL-7F-JL--7||LJLJL7F7|7L-JLJL7L-77FF.L7J.LJ.|-JLF
J7-L-JJ7FJ|FJFJF|||.F|.FLFJ|LJF-7FJ|||LJ|L7||FJ|7LJ|F7|7-FJ|-|||F7F-7F-JLJ||FJL7F-JL7LJLJL-7F-J|F7F-7|||F----J||L7F77LF-JF7L7-|F.|L-F7---JF|
.|7LF7|LJL--7JLL.F-FLJFL7L7|J-L7LJFJ|L-7|FJ||L7L-7FLJLJ-.L-J7LJ||||FJL--7LLJ|F-JL7F7L7F----JL-7|||L7LJLJL---7FJL7LJL7LL-7|L-J||LFF7.77-||.7.
7777LLJJFJ|-|.FL7J.|JF7|LJLJJJLL-7L7L--JLJ7||FJF7L7F-7LJ.||LJJ7||LJL7F--JLLFJL7|L|||FJL-7F7F-7|LJL7|F--7F---JL-7L7F-JJ.|LJ-||-7-F|--77LL|-L7
L77-7FLJ|JFJ|L77.F|JFJLL--L|--J-FJFJ7FLL..FJ||FJL7LJFJ-|-JJ-|-FJ|JLFJL--77.L--J7J||||J|FLJ||FJ|FF-JLJF-JL--7F-7L7|L7F-77.FLF|.|7FL|-JL7.||.|
|LFJLJF7J.|FF-|J-J|-L7-J|..L7FFJL7|LJ7L|.FL-J|L7FJF-J.F-7LL-F.L7|J7L7F7FJF|7|.F|.||||JJ7LFJ|L7L7|F7F-JJJF--J|JL-J|FJ7F---7.|L7JFF-LL-|LFJ-F7
JF|JLLF|.F-JJFL-|L7FLLL.L77FLL77LLJ|7|L|7-F--JFJL7L7J--J7JF7J77LJ-F-J||L7---FJ-L-LJLJLFL.L-JFJFJLJ|L7F7-L--7L---7||7JL.|-J7LFJL||L7FFJFJJ7|.
LL|7LL|J-F.|F7.F-JL|-|L77FFJ-|L-.|FFL7FJ|LL--7L7J|FJ.||FF-JJL-LL.FL-7|L-J7|J|F7|||-L|-J..|.|L7|J|LL7LJ|F---JF-7FJLJJ7|.L.|7FJ--J|JL-F-|J.FL7
FL||F7|JL7--JJFL77.|.L7.|.|.FFJ.--J|L|-.|.LLL|FJFJ|J--JFJ7LL7||L--|7LJL|7LJ.FJ.|FL-7||7F7||7J||-77.L--JL7F7FJFJ|LJFFF7-J..--LJ.||||7LJL|F7L|
FF-7LJ7|F|F|L-JLL-FF7-|L.FJFJ...FL-FJL--J7.7.LJJL7|L|-F--|7JF7||L|J|F|||7|L7JLL|7JF|||FLJ-|-7LJ.|--|LJ-FJ||L7|FJ7J|7FJ---|7F|F.|L7L7-F7||L--
.F|7-L|-FJF-.L|-|J|JLF7JL7.|L---||.F7|F.L.--..|LFLJ7J.7-F7J7.7-J-JJ|7FLJF|.F-77LJ7LJFF7FLJ|7|-|-|LF|-JFL-J|FJLJJ-7J|L|LFF--L-L7FL-FJJLFF|LF|
7JJ|-J.LL-|7L.F-LFJF7-J7||7|.|FL-77LJ7|.|-|||FF.F|JL7L--L|-F|.--LF7.LJL-7.FLF-J.F-|FJJ7JL--J|-7.J-7|..L7L-LJJLLJ7.FF7L7LJ.|--L|-.||.|.|.J-7J
7|F|-77LL-FL-F7J7|.L--L|FF7||J7|.FJ-L|-7|FL7.J|7|-J|LL-FJJ.7J7L-7|JF|.FJFJF-LJ.L|||7|-|7F|7L7||7L---.-.-L7||J..L|-7.J7-|F-7-JFL7L-F7-7L7-F-.
L|JJF777LLL--J|.J--7FFLLFJ|LJL|-JJF-JJ.|LJJ|7JFF.|.|.||||F-JJ.FLF--|.F7-|FLJFLJ|L7JLJ7.-L.||JFJL7L|JL|77||FJ...|..L7.F7F|7L7L|7FJJ.||L7J||L|
LLJF|LFJ7..7J-J-J-J-JJ7LLLLJ.F7J-JJJJ.LL-L----J--J7J..JJ|J|-L--.LL-J7JLL.L.FJ-LJ-LJLLL--|-|-.L-L7-J--LJ-7-7-FJ7-J-7.L-JLLJJ|JLJLF---|-L|-|.J
"""
)
