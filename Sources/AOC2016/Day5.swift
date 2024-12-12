import CryptoKit
import Shared

private func part1(input: String) -> String {
    let lazyHashes = (0...).lazy
        .map { (idx: Int) in
            md5(string: input.appending(String(idx)))
        }
        .filter { (digest: String) in
            return digest.prefix(5) == "00000"
        }
        .prefix(8)
    let hashes = Array(lazyHashes)
    return hashes.map { $0.dropFirst(5).prefix(1) }.joined(separator: "")
}

private func part2(input: String) -> String {
    var password = (0..<8).map { _ in " " }
    var idx = 0
    while password.contains(where: { $0 == " " }) {
        let digest = md5(string: input.appending(String(idx)))
        if digest.prefix(5) == "00000",
            let position = Int(digest.dropFirst(5).prefix(1)),
            position < password.count,
            password[position] == " " {
            print("found", digest)
            password[position] = String(digest.dropFirst(6).prefix(1))
        }
        idx += 1
    }
    return password.joined(separator: "")
}

public let day5 = Solution(
    name: "day5",
    part1: part1,
    part2: part2
)
