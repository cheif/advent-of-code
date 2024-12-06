import Shared

private func part1(input: String) -> Int {
    let rooms = input.split(whereSeparator: \.isNewline).map { line in
        let splits = line.split(separator: "-")
        let lastSplit = splits.last!.split(separator: "[")
        return (
            letters: splits.dropLast().joined().map { $0 }.grouped(by: \.self).mapValues(\.count),
            id: Int(lastSplit[0])!,
            checksum: lastSplit[1].split(separator: "]")[0]
        )
    }
    let real = rooms.filter { checksum(for: $0.letters) == $0.checksum }
    return real.map(\.id).sum
}

private func part2(input: String) -> Int {
    let rooms = input.split(whereSeparator: \.isNewline).map { line in
        let splits = line.split(separator: "-")
        let lastSplit = splits.last!.split(separator: "[")
        return (
            letters: Array(splits.dropLast().joined(by: "-")),
            id: Int(lastSplit[0])!
        )
    }
    let decrypted = rooms.map { room in
        let characters = room.letters
            .map { character in
                if character == "-" {
                    return Character(" ")
                } else {
                    let ascii = (Int(character.asciiValue!) - 97 + room.id) % 26 + 97
                    return Character(UnicodeScalar(ascii)!)
                }
            }
        return (String(characters), room.id)
    }
    return decrypted.first(where: { $0.0 == "northpole object storage" })?.1 ?? 0
}

private func checksum(for letters: [Character: Int]) -> String {
    let characters = letters
        .sorted(by: { $0.key < $1.key })
        .sorted(by: { $0.value > $1.value })
        .map(\.key)
        .prefix(5)
    return String(characters)
}

private func isValid(triangle: [Int]) -> Bool {
    let sorted = triangle.sorted()
    return sorted.dropLast().sum > sorted.last!
}

public let day4 = Solution(
    name: "day4",
    part1: part1,
    part2: part2
)
