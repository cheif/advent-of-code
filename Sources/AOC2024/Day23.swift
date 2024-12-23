import Shared

private func part1(input: String) -> String {
    let connections = input.split(whereSeparator: \.isNewline).map { l in 
        let s = l.split(separator: "-").map { String($0) }
        return Set([s[0], s[1]])
    }
    let computers = Set(connections.flatMap { $0 })
    let threes = computers
        .filter { $0.starts(with: "t") }
        .flatMap { (c: String) -> [Set<String>] in 
            let conns: Set<String> = Set(connections
                .filter { $0.contains(c) }
                .compactMap { $0.first { $0 != c } })
            let all: [[String]] = conns.combinations(ofCount: 2)
                .filter { comps in 
                    connections.contains(Set(comps))
                }
                .map { aa -> [String] in aa + [c] }
            return all.map { Set($0) } 
        }
    return "\(Set(threes).count)"
}

private func part2(input: String) -> String {
    let conns = parse(input: input)
    let lans = conns.keys
        .map { c in allConnections(in: Set([c]), in: conns) }
    let biggest = Set(lans).max { $0.count < $1.count }!
    return biggest.sorted().joined(separator: ",")
}

private func allConnections(in current: Set<String>, in conns: [String: Set<String>]) -> Set<String> {
    let computers = Set(conns.keys)
    let candidate: String? = computers
        .subtracting(current)
        .first { cand in 
            current.allSatisfy { c in 
                conns[c]!.contains(cand)
            }
        }
    if let candidate {
        return allConnections(in: current.union([candidate]), in: conns)
    } else {
        return current
    }
}

private func parse(input: String) -> [String: Set<String>] {
    let connections = input.split(whereSeparator: \.isNewline).map { l in 
        let s = l.split(separator: "-").map { String($0) }
        return Set([s[0], s[1]])
    }
    let computers = Set(connections.flatMap { $0 })
    return Dictionary(uniqueKeysWithValues: computers
        .map { comp in
            let connectedTo = connections
                .filter { $0.contains(comp) }
                .flatMap { $0 }
            return (comp, Set(connectedTo))
        }
    )
}

public let day23 = Solution(
    name: "day23",
    part1: part1,
    part2: part2
)
