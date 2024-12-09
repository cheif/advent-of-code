import Algorithms
import Shared

private func part1(input: String) -> Int {
    let blocks: [[Int?]] = input.map { Int(String($0))! }.chunks(ofCount: 2).enumerated().flatMap { id, chunk in
        return [(0..<chunk.first!).map { _ in id }, (0..<chunk.last!).map { _ in nil }]
    }
    var flattened = blocks.flatMap(\.self)
    var emptyOffsets = flattened.enumerated().filter { $0.element == nil }.map(\.offset)
    for offset in flattened.indices.reversed() {
        guard let d = flattened[offset],
              let target = emptyOffsets.first,
              target < offset
        else { continue }
        flattened[target] = d
        flattened[offset] = nil
        emptyOffsets.removeFirst()
    }
    return flattened.enumerated().compactMap { offset, eln in (eln ?? 0) * offset }.sum
}

private func part2(input: String) -> Int {
    let blocks: [[Int?]] = input.map { Int(String($0))! }.chunks(ofCount: 2).enumerated().flatMap { id, chunk in
        return [(0..<chunk.first!).map { _ in id }, (0..<chunk.last!).map { _ in nil }]
    }
    var flattened = blocks.flatMap(\.self)
    let chunks = Array(flattened.enumerated()).chunked(by: { $0.element == $1.element })
    let files = chunks.filter { $0.allSatisfy { $0.element != nil }}.reversed()
    var emptyOffsets = chunks.filter { $0.allSatisfy { $0.element == nil }}
    for file in files {
        let size = file.count
        guard
            let targetIndex = emptyOffsets.firstIndex(where: { $0.count >= size }),
            emptyOffsets[targetIndex].first!.offset < file.first!.offset
        else {
            continue
        }

        let target = emptyOffsets[targetIndex]
        for p in file {
            let offset = file.last!.offset - p.offset
            flattened[target.first!.offset + offset] = p.element
            flattened[p.offset] = nil
        }

        emptyOffsets[targetIndex] = target.dropFirst(file.count)
    }
    return flattened.enumerated().compactMap { offset, eln in (eln ?? 0) * offset }.sum
}

public let day9 = Solution(
    name: "day9",
    part1: part1,
    part2: part2
)
