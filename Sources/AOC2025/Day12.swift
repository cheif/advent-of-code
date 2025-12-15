import Algorithms
import Shared

private func part1(input: String) -> Int {
    let splits = input.split(separator: "\n\n")
    let presents = splits.dropLast().map { s in
        let g = Grid(string: String(s.dropFirst(3)))
        return Grid(data: g.data.filter { $0.val == "#" })

    }
    let withRotations = presents.map { $0.rotations() }
    let regions = splits.last!.split(whereSeparator: \.isNewline).map(Region.init)
    return regions.filter { $0.canFit(presents: withRotations, no: 0) }.count
}

private func part2(input: String) -> Int {
    return 0
}

struct Region {
    let grid: Grid<Character>
    let quantities: [Int]

    func canFit(presents: [[Grid<Character>]], no: Int) -> Bool {
        if no == 0 {
            // Some optimizations when the grid is empty
            let totalPresentArea = quantities.enumerated().map { present, count in
                presents[present].first!.data.filter { $0.val == "#" }.count * count
            }.sum
            if totalPresentArea > grid.size {
                return false
            }
            let totalPresentBounding = quantities.enumerated().map { present, count in
                presents[present].first!.size * count
            }.sum
            if totalPresentBounding <= grid.size {
                return true
            }
        }
        guard let toFit = quantities.firstIndex(where: { $0 > 0 }) else {
            return true
        }
        var newQuantities = quantities
        newQuantities[toFit] -= 1
        var withRotations = presents[toFit]
        if no == 0 {
            withRotations = Array(withRotations.prefix(2))
        }
        return
            withRotations
            .flatMap { grid.waysToFit(other: $0, no: no) }
            .map { grid in
                Region(grid: grid, quantities: newQuantities)
            }
            .contains(where: { $0.canFit(presents: presents, no: no + 1) })

    }
}

extension Grid<Character> {
    var size: Int {
        xRange.count * yRange.count
    }

    func waysToFit(other: Grid<Character>, no: Int) -> [Self] {
        let xCandidates = xRange.lowerBound...(xRange.upperBound - other.xRange.count + 1)
        let yCandidates = yRange.lowerBound...(yRange.upperBound - other.yRange.count + 1)
        let alreadyFilled = Set(data.filter { $0.val != "." }.map(\.position))
        return xCandidates.flatMap { x in
            yCandidates.compactMap { y -> Self? in
                let newPoints = other.data.map {
                    Point(x: $0.x + x, y: $0.y + y, val: Character(UnicodeScalar(65 + no)!))
                }
                let newPositions = newPoints.map(\.position)
                guard alreadyFilled.intersection(newPositions).isEmpty else {
                    return nil
                }
                return Grid(
                    data: data.filter { !newPositions.contains($0.position) }
                        + newPoints
                )
            }
        }
    }

    func rotations() -> [Self] {
        Array(
            [
                self,
                self.rotated(),
                self.rotated().rotated(),
                self.rotated().rotated().rotated(),
            ].uniqued())
    }

    func rotated() -> Self {
        Grid(data: data.map { Point(x: yRange.upperBound - $0.y, y: $0.x, val: $0.val) })
    }
}

extension Region {
    init(l: some StringProtocol) {
        let splits = l.split(whereSeparator: \.isWhitespace)
        let size = splits.first!.dropLast().split(separator: "x").map { Int($0)! }
        let positions = (0..<size[0]).flatMap { x in (0..<size[1]).map { y in Position(x: x, y: y) }
        }
        let grid = Grid<Character>(data: positions.map { Grid.Point(x: $0.x, y: $0.y, val: ".") })
        self.init(
            grid: grid,
            quantities: Array(splits.dropFirst().map { Int($0)! })
        )
    }
}

public let day12 = Solution(
    name: "day12",
    part1: part1,
    part2: part2
)
