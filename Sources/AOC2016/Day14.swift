import Foundation
import Shared

private func part1(input: String) -> Int {
    var keys: [(Int, String)] = []
    var i = 0
    while keys.count < 64 {
        let hash = md5Cached(string: input + String(i))
        if let triple = findTriple(string: hash) {
            let nextThousand = (0..<1000).map { md5Cached(string: input + String(i + 1 + $0)) }
            if nextThousand.contains(where: { $0.contains(triple) }) {
                keys.append((i, hash))
            }
        }
        i += 1
    }
    return keys.last!.0
}

private func part2(input: String) -> Int {
    var keys: [(Int, String)] = []
    var i = 0
    while keys.count < 64 {
        let hash = stretched(string: input + String(i))
        if let triple = findTriple(string: hash) {
            let nextThousand = (0..<1000).map { stretched(string: input + String(i + 1 + $0)) }
            if nextThousand.contains(where: { $0.contains(triple) }) {
                keys.append((i, hash))
            }
        }
        i += 1
    }
    // 15019 is too low
    return keys.last!.0
}

private var stretchedCache: [String: String] = [:]
private func stretched(string: String) -> String {
    if let stretched = stretchedCache[string] {
        return stretched
    }
    let stretched = (0...2016).reduce(string) { str, _ in md5(string: str) }
    stretchedCache[string] = stretched
    return stretched
}

private var cache: [String: String] = [:]
private func md5Cached(string: String) -> String {
    if let match = cache[string] {
        return match
    }

    let match = md5(string: string)
    cache[string] = match
    return match
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
