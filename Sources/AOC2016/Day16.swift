import Shared

private func part1(input: String) -> String {
    let size = input.count > 5 ? 272 : 20
    var filled = input
    while filled.count < size {
        let b = filled.reversed().map { $0 == "0" ? "1" : "0" }.joined()
        filled += "0" + b
    }
    return checksum(String(filled.prefix(size)))
}

private func part2(input: String) -> String {
    let size = 35651584
    var filled = input
    while filled.count < size {
        let b = filled.reversed().map { $0 == "0" ? "1" : "0" }.joined()
        filled += "0" + b
        print(filled.count)
    }
    return checksum(String(filled.prefix(size)))
}

private func checksum(_ input: String) -> String {
    print("input", input.count)
    let res = input.chunks(ofCount: 2).map { pair in 
        pair.first == pair.last ? "1" : "0"
    }.joined()
    return res.count % 2 == 0 ? checksum(res) : res
}

public let day16 = Solution(
    name: "day16",
    part1: part1,
    part2: part2
)
