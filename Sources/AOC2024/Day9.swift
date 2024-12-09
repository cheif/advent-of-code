import Algorithms
import Shared

private func part1(input: String) -> Int {
    var blocks = input.map { Int(String($0))! }.chunks(ofCount: 2).enumerated().map { id, chunk in
        return ((0..<chunk.first!).map { _ in id }, chunk.last!)
    }
    while let firstWithEmpty = blocks.enumerated().first(where: { $0.element.1 != 0 }), firstWithEmpty.offset != blocks.count - 1 {
        blocks[firstWithEmpty.offset].1 -= 1
        var last = blocks.popLast()!
        guard let eln = last.0.popLast() else {
            break
        }
        blocks[firstWithEmpty.offset].0 += [eln]
        if !last.0.isEmpty {
            blocks.append(last)
        }
    }
    let flattened = blocks.flatMap(\.0)
    return flattened.enumerated().map { $0 * $1 }.sum
}

private func part2(input: String) -> Int {
    var blocks: [[Int?]] = input.map { Int(String($0))! }.chunks(ofCount: 2).enumerated().flatMap { id, chunk in
        return [(0..<chunk.first!).map { _ in id }, (0..<chunk.last!).map { _ in nil }]
    }
    let idsToCheck = blocks.compactMap(\.first).compactMap({ $0 }).sorted().reversed()
    print(idsToCheck.count)
    for id in idsToCheck {
        if id % 100 == 0 {
            print("Checking: \(id)")
        }
        let offset = blocks.enumerated().first(where: { $0.element.contains(id) })!.offset
        let file = blocks[offset]
        let size = file.count
        guard let target = blocks.enumerated()
            .prefix(offset)
            .first(where: { $0.element.filter { $0 == nil }.count >= size }) else {
            continue
        }

        blocks[target.offset] = target.element.dropLast(file.count)
        blocks[offset] = (0..<file.count).map { _ in nil }
        blocks.insert(file, at: target.offset)
    }
    return blocks.flatMap { $0 }.enumerated().compactMap { offset, eln in (eln ?? 0) * offset }.sum
}

public let day9 = Solution(
    name: "day9",
    part1: part1,
    part2: part2
)
