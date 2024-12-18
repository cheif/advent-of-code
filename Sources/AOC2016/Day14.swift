import Foundation
import Shared

private func part1(input: String) -> Int {
    let memoizedMD5 = memoize(md5)
    var keys: [(Int, String)] = []
    var i = 0
    while keys.count < 64 {
        let hash = memoizedMD5(input + String(i))
        if let triple = findTriple(string: hash) {
            let nextThousand = (0..<1000).map { memoizedMD5(input + String(i + 1 + $0)) }
            if nextThousand.contains(where: { $0.contains(triple) }) {
                keys.append((i, hash))
            }
        }
        i += 1
    }
    return keys.last!.0
}

private func part2(input: String) -> Int {
    let memoizedMD5 = memoize(md5)
    let memoizedStretched = memoize {
        stretched(string: $0, md5: memoizedMD5)
    }
    var keys: [(Int, String)] = []
    var i = 0
    while keys.count < 64 {
        let hash = memoizedStretched(String(i))
        if let triple = findTriple(string: hash) {
            let nextThousand = (0..<1000).map { memoizedStretched(String(i + 1 + $0)) }
            if nextThousand.contains(where: { $0.contains(triple) }) {
                keys.append((i, hash))
            }
        }
        i += 1
    }
    // 15019 is too low
    return keys.last!.0
}

private func stretched(string: String, md5: (String) -> String) -> (String) {
    return (0...2016).reduce(string) { str, _ in md5(str) }
}

private func findTriple(string: String) -> String? {
    string
        .chunked { $0 == $1 }
        .first { $0.count >= 3 }
        .map { $0.prefix(1) }
        .map { c in (0..<5).map { _ in String(c) }.joined(separator: "") }
}

public let day14 = Solution(
    name: "day14",
    part1: part1,
    part2: part2
)
