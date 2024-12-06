import CryptoKit
import Shared

private func part1(input: String) -> String {
    let hashes = (0...).lazy
        .map { idx in
            let data = input.appending("\(idx)").data(using: .utf8)!
//            print("Hashing: \(String(data: data, encoding: .utf8))")
            return Insecure.MD5.hash(data: data).map { String(format: "%02hhx", $0) }.joined()
        }
        .filter { (digest: String) in
//            print("testing", digest)
            return digest.prefix(5) == "00000"
        }
        .prefix(1)
    print(Array(hashes))
    return ""
}

private func part2(input: String) -> String {
    return ""
}

public let day5 = Solution(
    name: "day5",
    part1: part1,
    part2: part2
)
