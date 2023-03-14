public func day12() {
//    print(part1(input: input))
    print(part2(input: input))
}

private func part1(input: String) -> Int {
    let grid = Grid(lines: input.split(whereSeparator: \.isNewline).map { $0.map { $0 }})
    let start = grid.data.first(where: { $0.val == "S" })!
    let end = grid.data.first(where: { $0.val == "E" })!
    let shortest = grid.aStar(start: start, end: end)!
    plot(path: shortest)
   
    print(shortest)
    return shortest.count - 1
}

private func part2(input: String) -> Int {
    let grid = Grid(lines: input.split(whereSeparator: \.isNewline).map { $0.map { $0 }})
    let starts = grid.data.filter { $0.val == "S" || $0.val == "a" }
        .filter { point in !grid.neighbours(to: point).allSatisfy { $0.val == point.val } }
    print("Candidate starts: \(starts.count)")
    let end = grid.data.first(where: { $0.val == "E" })!
    let routes = starts.enumerated().compactMap { idx, start in 
        print("Checking: \(idx)")
        return grid.aStar(start: start, end: end) { point in
            point.val != "a"
        }
    }
    let shortest = routes.sorted(by: { $0.count < $1.count }).first!
    plot(path: shortest)
   
    print(shortest)
    return shortest.count - 1
}

private func plot(path: [Grid<Character>.Point]) { 
    let positions = path.map { Position(x: $0.x, y: $0.y) }
    let toPlot = zip(positions, positions.dropFirst()).map { start, end in 
    let char: String
    if end.y > start.y {
        char = "v"
    } else if end.y < start.y {
        char = "^"
    } else if end.x > start.x {
        char = ">"
    } else {
        char = "<"
    }
        return (start, char)
    }
    plot(toPlot)
}

private func reconstructPath(cameFrom: [Grid<Character>.Point: Grid<Character>.Point], current: Grid<Character>.Point) -> [Grid<Character>.Point] {
    var current = current
    var cameFrom = cameFrom
    var path = [current]
    while cameFrom.keys.contains(current) {
        current = cameFrom[current]!
        path.insert(current, at: 0)
    }
    return path
}

private extension Grid where V == Character {
    func aStar(
        start: Grid<Character>.Point, 
        end: Grid<Character>.Point, 
        extraNeighbourFilter: (Point) -> Bool = { _ in true }
    ) -> [Grid<Character>.Point]? {
        var open = Set([start])
        var cameFrom: [Point: Point] = [:]
        var gScore: [Point: Int] = [start: 0]
        var fScore: [Point: Int] = [start: start.distance(to: end)]
        
        while !open.isEmpty {
            let current = open.sorted { fScore[$0]! < fScore[$1]! }.first!
            open.remove(current)
            if current == end {
                return reconstructPath(cameFrom: cameFrom, current: current)
            }
            let neighbours = self.neighbours(to: current)
                .filter { point in
                    if current.val == "S" {
                        return true
                    } else if point == end {
                        return current.val == "z" || current.val == "y"
                    } else {
                        return point.val.asciiValue! <= current.val.asciiValue! + 1
                    }
                }
                .filter(extraNeighbourFilter)
            for neighbour in neighbours {
                let tentativeGScore = gScore[current]! + 1
                if let current = gScore[neighbour],
                   current <= tentativeGScore {
                    // Current is better, do nothing
                    continue
                } else {
                    cameFrom[neighbour] = current
                    gScore[neighbour] = tentativeGScore
                    fScore[neighbour] = tentativeGScore + neighbour.distance(to: end)
                    open.insert(neighbour)
                }
            }
        }
        return nil
    }
    
    func neighbours(to point: Point) -> [Point] {
        adjacent(to: point)
            .values
            .compactMap(\.first)
    }
}

private let test = """
Sabqponm
abcryxxl
accszExk
acctuvwj
abdefghi
"""

private let input = """
abcccccccccccccccccccccccccccccccccccccccccccccccccccaaaaacccccccccccccaaaaaaaccccccccccccccccaaaaaaccccccccccccccccccccccccccaaaaacccaaaccccccccccccccccccccccccccccccaaaaa
abcccccccccaaaccccccccccccaaaccccccccccccccccccccccccaaaaaacccccccccccccaaaaaaaaaaaccaaaaccccaaaaaaacccccccccccccccccccccccccccaaaaaacaaaaccccccccccccccccccccccccccccccaaaa
abcccccccccaaaaaacccccccccaaaacccccccccccccccccccccccaaaaaaccccccccccccaaaaaaaaaaaccaaaaacccaaaaaacccccccccaaacccccccccccccccaaaaaaaacaaaaccccccccccccccccacccccccccccccaaaa
abcccccccccaaaaaacccccccccaaaaccccaacccccccccccccccccaaaaaaccccccccccaaaaaaaaaaaaaacaaaaaaccaacaaaccaacccaaaaaaccccccccccccccaaaaaaaacaaaccccccccccaccccaaaccccccccccccaaaaa
abcccccccaaaaaaaccccccccccaaaacccaaaaccccccccccccaaccccaaacccccccaaacaaaaaaaaaccccccaaaaaacccccaaaccaacccaaaaaacccccccccccccccccaaccccccccccccccccaaacccaaaccccccccccccaaaca
abcccccccaaaaaaacccccccaaacccccccaaaacccccccaaccaaaccccccccccccaaaaacaaaaaaaaaccccccaaaaaccccccccaaaaaaaacaaaaaccaacaaccccccccccaaccccccccccccccccaaaaaaaaaccccccccccccccccc
abcccccccccaaaaaaccaaccaaacccccccaaaacccccccaaaaaaaccccccccccccaaaaaaccccaaaaaacccccccaaaccccccccaaaaaaaaaaaaacccaaaaacccccccaaaccccccccccccccccccaaaaaaaackcccccccccccccccc
abcccccccccaaaaaaccaaaaaaaccccccccccccccccccaaaaaacccccccccccccaaaaaaccccaaaaaaccccccccccccccccccccaaaaccaaaaaccccaaaaaccccccaaaaaccccaaaaaccccccccaaaajjkkkkkccccccaacccccc
abcccccccccaaccccccaaaaaaccccccccccccccccccccaaaaaaaaccccccccccaaaaacccaaaacaaccccccccccccccccccccaaaaaccccccccccaaaaaacccccaaaaaaccccaaaaaccciijjjjjjjjjkkkkkkccaaaaaaccccc
abcaaaccccccccccccccaaaaaaaaccccccccccccccccaaaaaaaaacccccccccccaaaacccaaaccaaccccccccccccccccccccaacaaacccccccccaaaacccccccaaaaaacccaaaaaaciiiijjjjjjjjjoopkkkkcaaaaacccccc
abaaaacccccccccccccaaaaaaaaaccccccccccccccccaaaaaaaacccccccccccccccccccaaaaaaaccccaccaccccccccccccacccaacccccccccccaaccccccccaaaaacccaaaaaaiiiiiijjjjjjoooppppkkcaaaaaaacccc
abaaaaaccccccccccccaaaaaaaaccccccccccccccccaaaaaaaccccccccccccccccccccccaaaaaaccccaaaacccccccccccccccccccccccccccccccccccccccaaaaccccaaaaaiiiinnnoooooooooppppkkkaaaaaaacccc
abaaaaacccccccccccaaaaaaaccccccccccccccccccccccaaacccccccccccccccccccaaaaaaaacccccaaaaccccccccccccaaccaacccccaccccacccccccccccccccccccaaaciiinnnnoooooooouupppkkkaaaaaaacccc
abaaaaccccccccccccccccaaaccccccccccccccccccccccaaacccccccaaccccccccccaaaaaaaaacccaaaaaacccccccccccaaaaaaccccaaaaaaaacccccccccccccaaccccccciiinnnntttooouuuuupppiiacaaacccccc
abaaaacccccccccccccccccaaccccccccccccccccccccccccccccccaaaacacccccccccaaaaaaaacccaaaaaacccccccccccaaaaaccccccaaaaaacccccccccccaaaaaacccccciinnnttttuuuuuuuuuuppiiccaaacccccc
abcccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaacccccccccccaaaaaaaccccaacccccaaccccccaaaaaacccccaaaaaacccccccccccaaaaaccccccciinnntttttuuuuxyuuuppiiicccccccccc
abccccccccccccccccccccccccccccccccccccaaacccccccaaccccccaaaaccccccccccccaaccccccccccccccccaacaaacaaaaaaaacccaaaaaaaaccccccccccaaaaaaaccccchinnnttxxxxuuxyyyuuppiiiiccccccccc
abccccccccccccccccccccccccccccccccccccaaaaaaccccaaacccccaaaaccccccccccccaaccccccccccccccccaaaaaccaaaaaaaaccaaaaaaaaaaccccccccaaaaaaaaccccchhhnnttxxxxxxxyyuvppppiiiccccccccc
abccccccccccccccccccccccccccccccccccaaaaaaaaaaccaaaaaaacacaacccccccccccccccccaaaccccccccaaaaaaccccccaacccccaaaaaaaaaaccccccccaaaaaaaaccccchhhnntttxxxxxxyyvvvppqqiiicccccccc
abccccccccccccccccccccccccccccaacaccaaaaaaaaaaaaaaaaaaacccccccccccccccccccccaaaaaaccccccaaaaaaacccccaacccccaccaaaaacacccccccccacaaaccccccchhhnnnttxxxxxyyyvvvvqqqqiiiccccccc
SbccccccccccccccccccccccccccccaaaaccaaaaaaacaaaaaaaaaaccccccccccccccccccccccaaaaaaccccccccaaaaaaccccccccccccccaaaaccccccccccccccaaacccccchhhmmmtttxxxEzzyyyyvvvqqqqiiccccccc
abcccccccccccccccccccccccccccaaaaaccccaaaaaccaaaaaaaaacccccccccccccccaaaaaccaaaaaaccccccccaaccaacccccccccccccccaacccccccaaaaccccccccccccchhhmmmtttxxxyyyyyyyyvvvqqqjjjcccccc
abcccaaacccccccccccccccccccccaaaaaacccaacaaaaaaaaaaaaacccccccccccccccaaaaacccaaaaaccccccccaacccccccccccccccccccccccccccaaaaacccccccccccchhhmmmttsxxyyyyyyyyvvvvvqqqjjjcccccc
abcccaaaaaacccaacaaccccccccccacaaaacccaacccaaaaaaaaaaaacccccccccccccaaaaaacccaacaaccccccccccccccccccccccccccccccccaacccaaaaaaccccccccccchhhmmmssxxwwwwyyywvvvvvqqqjjjjcccccc
abccaaaaaaacccaaaaaccccccccccccaaccccccccccaaaaaaaccaaccccccccccccccaaaaaacccccccccccccccccccccccccccccccccccaaccaaacccaaaaaacccccccaaachhhmmssswwwwwwyyywvvqqqqqqjjjccccccc
abcaaaaaaacccccaaaaacccccccccccccccccccccccccccaaaccccccccccccccccccaaaaaacccccccccccaaccccaaccccccccccccccccaaacaaacccaaaaaacccccccaaacgggmmsssswwwswwyywwrrqqqjjjjcccccccc
abcaaaaaaaccccaaaaaacccccccccccccccccccccccaaccaaaccccccccccccccccccccaaccccccccccccaaccccaaaacccccccccccccccaaaaaaccccccaacccccccaacaaagggmmmssssssswwwwwwrrqjjjjjddccccccc
abcccaaaaaacccaaaacccccccccccccccccccccccccaaacaaccccccccccccccccccccccccccccccccaaaaacaacaaaaccccccccccccccccaaaaaaaaccccccccccccaaaaaagggmmmmssssssswwwwrrrkjjjjddddcccccc
abcccaaaaaacccccaaccccccccccccccccccccccccccaaaaaccccccccccccccccccccccccccccccccaaaaaaaacaaaacaaccccccaaccaaaaaaaaaaacccccccccccccaaaaaggggmmmmllllsrrwwwrrkkkjdddddaaacccc
abcccaaaccccccccccccaacccccccccccccccccccccaaaaaaccccccccccccccccccccccccccccccccccaaaaacccccccaaaaaaccaaaaaaaaaaaaaacccccccccccccccaaaaaggggmmllllllrrrrrrrkkkdddddaaaccccc
abccccaaaaaaccccccccaacaaaccccccccacccaaccaaaaaaaaccccccccccaaaccccccaacccccccccccaaaaaccccccccaaaaacccaaaaaaaaaaaaccccccccccccccccaaacaacggggggflllllrrrrrrkkddddaaaaaccccc
abccccaaaaacccccccccaaaaacccccccccaaaaaaccaaaaaaaaccccccccccaaacacccaaaaccccccccccaacaaacccccaaaaaaccccaaaaaaaccaaacccccccccccccccccaacccccggggffffllllrrrrkkkdddaaaaaaacccc
abccaaaaaaacccccccaaaaaaccccccccccaaaaaccccccaacccccaaccccaacaaaaaccaaaacccccccaaccccaaccccccaaaaaaaccaaaaaaaaccaaaccccccccccccccccccaaaccccccgffffflllkkkkkkeedaaaaaaaacccc
abccaaaaaaacccccccaaaaaaacccccccccaaaaaacccccaacccccaaacccaaaaaaaaccaaaacccaaaaacccccccccccccccaaaaaacaaaaaaaacccccccccccccccccccccccaaaacaacccccffffllkkkkkeeedccaaaaaacccc
abccccaaaaaaccccccccaaaaaacccccccaaaaaaaacccccaaccccaaaaaaaaaaaaccccccccccaaaaaaaacccccccccccccaaccaaccccaaaccccccaacccccccccccccccccaaaaaaaccccccfffffkkkkeeeecccaacccccccc
abccccaaccaaccccccccaaccaacccccccaaaaaaaacccccaaccaaaaaaaaccaaaaacccccccccaaaaaaaaccccccccccaacaaccccccccaaccccaacaaaccccaacccccccccccaaaaaaccccccaafffeeeeeeecccccccccccccc
abccccaaccccccccccccaaccccccccccccccaacccccaaaaaaaaaaaaaaacaaacaaaaaaacaccaaaaaaacccccccaaacaacccccccccccccccccaaaaaccccaaaacccccccaaaaaaaaccccccaaaaffeeeeeeeccccccccccccca
abacccccccccccccaaacccccccccccccccccaacccccaaaaaaaaaaaaaacccaaccaaaaaaaaaaaaaccaaacccccccaaaaaccccccccccccccccccaaaaaaccaaaacccccccaaaaaaaaaccccccaaacceeeeeccccccccccccccaa
abaaccccccccccaaaaaacccccccccccccccccccccccccaaaacccaaaaaaccccccaaaaaaaaaaaaaaaaaaaccccccaaaaaaacccaaaccccccccaaaaaaaaccaaaaccccccccaaaaaaaaccccccccccccaaacccccccccccaaacaa
abaaccccccccccaaaaaacccccccccccccccccccccccccaaaaacaaaaaaaccccccaaaaaaaaaaaaaaaaaaccccccaaaaaaaaccccaaaaccccccaaaaacaaccccccccccccccccaaaaaaacccccccccccacacccccccccccaaaaaa
abacccccccccccaaaaaaccccccccccccccccccccccccaaaaaacaaaccaaccccccaaaaaaccaaaaaaaaccccccccaaaaaaaaccaaaaaacccccccccaaaccccccccccccccccccaacccccccccccccccccccccccccccccccaaaaa
"""
