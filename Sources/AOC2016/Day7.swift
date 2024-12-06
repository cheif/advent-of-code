import Shared

private func part1(input: String) -> Int {
    let ips = parse(input: input)
    let supportsTLS = ips.filter { ip in
        let hasOuter = ip.supernets.contains { containsABBA($0.map { $0 })}
        let hasInner = ip.hypernets.contains { containsABBA($0.map { $0 })}
        return hasOuter && !hasInner
    }
    return supportsTLS.count
}

private func part2(input: String) -> Int {
    let ips = parse(input: input)
    let supportsSSL = ips.filter { ip in
        let abas = ip.supernets.flatMap { getABAs($0.map { $0 })}
        let babs = ip.hypernets.flatMap { getABAs($0.map { $0 })}
        return babs.contains { bab in
            abas.contains { aba in corresponds(aba: aba, bab: bab) }
        }
    }
    return supportsSSL.count
}

private func parse(input: String) -> [(supernets: [Substring], hypernets: [Substring])] {
    let ips = input.split(whereSeparator: \.isNewline)
    return ips.map { ip in
        let split = ip.split(separator: "[")
        var supernets = [split[0]]
        var hypernets: [Substring] = []
        for split in split.dropFirst() {
            let inner = split.split(separator: "]")
            assert(inner.count == 2)
            hypernets.append(inner[0])
            supernets.append(inner[1])
        }
        return (supernets, hypernets)
    }
}

private func containsABBA(_ str: [Character]) -> Bool {
    (0..<(str.count - 3)).contains(where: { start -> Bool in
        let a = str[start] == str[start+3]
        let b = str[start+1] == str[start+2]
        let c = str[start] == str[start+1]
        return a && b && !c
    })
}

private func getABAs(_ str: [Character]) -> [String] {
    (0..<(str.count - 2)).compactMap { start -> String? in
        if str[start] == str[start+2] {
            return String(str.dropFirst(start).prefix(3))
        } else {
            return nil
        }
    }
}

private func corresponds(aba: String, bab: String) -> Bool {
    let chars = aba.map { $0 }
    let converted = String([chars[1], chars[0], chars[1]])
    return converted == bab
}

public let day7 = Solution(
    name: "day7",
    part1: part1,
    part2: part2
)
