import Algorithms
import Shared

private func part1(input: String) -> Int {
    let map = Grid(string: input)
    let antennas = map.data.filter { $0.val != "." }.grouped(by: \.val)
    let antinodes = antennas
        .flatMap { freq, locations in
            let pairs = locations.combinations(ofCount: 2)
            return pairs.flatMap { pair in
                let distance = (pair[0].x - pair[1].x, pair[0].y - pair[1].y)
                let anti = [
                    pair[1].move(in: .left, step: distance.0).move(in: .up, step: distance.1),
                    pair[0].move(in: .right, step: distance.0).move(in: .down, step: distance.1),
                ].map(\.position)
                return anti
            }
        }
        .filter { map.xRange.contains($0.x) && map.yRange.contains($0.y) }
    let unique = Set(antinodes)

    return unique.count
}

private func part2(input: String) -> Int {
    let map = Grid(string: input)
    let antennas = map.data.filter { $0.val != "." }.grouped(by: \.val)
    let antinodes = antennas
        .flatMap { freq, locations in
            let pairs = locations.combinations(ofCount: 2)
            return pairs.flatMap { pair -> [Position] in
                let distance = (pair[1].x - pair[0].x, pair[1].y - pair[0].y)
                return (0..<100).flatMap { offset in
                    return [
                        pair[0].move(in: .left, step: distance.0 * offset).move(in: .up, step: distance.1 * offset),
                        pair[1].move(in: .right, step: distance.0 * offset).move(in: .down, step: distance.1 * offset),
                    ].map(\.position)
                }
            }
        }
        .filter { map.xRange.contains($0.x) && map.yRange.contains($0.y) }
    let unique = Set(antinodes)

    return unique.count
}
public let day8 = Solution(
    name: "day8",
    part1: part1,
    part2: part2
)
