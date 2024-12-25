import Shared

private func part1(input: String) -> String {
    let split = input.split(separator: "\n\n")
    var values = Dictionary(
        uniqueKeysWithValues: split[0].split(whereSeparator: \.isNewline).map { l in
            let s = l.split(separator: ": ")
            return (String(s[0]), Int(s[1])!)
        })
    let connections = Dictionary(
        uniqueKeysWithValues: split[1].split(whereSeparator: \.isNewline).map { l in
            let s = l.split(separator: " -> ")
            return (String(s[1]), s[0].split(separator: " ").map { String($0) })
        })
    values = simulate(values: values, connections: connections)
    let zVals = values.filter { $0.key.starts(with: "z") }.sorted { $0.key < $1.key }.map(\.value)
    return "\(zVals.enumerated().map { off, v in v << off }.sum)"
}

private func part2(input: String) -> String {
    let split = input.split(separator: "\n\n")
    let values = Dictionary(
        uniqueKeysWithValues: split[0].split(whereSeparator: \.isNewline).map { l in
            let s = l.split(separator: ": ")
            return (String(s[0]), Int(s[1])!)
        })
    let connections = Dictionary(
        uniqueKeysWithValues: split[1].split(whereSeparator: \.isNewline).map { l in
            let s = l.split(separator: " -> ")
            return (String(s[1]), s[0].split(separator: " ").map { String($0) })
        })

    let zs = connections.keys.filter { $0.starts(with: "z") }.sorted().dropFirst().dropLast()
    var swaps: [[String]] = []
    for z in zs {
        let c = connections[z]!
        let xBase = z.replacingOccurrences(of: "z", with: "x")
        let firstXOR = connections.first(where: {
            $0.value[1] == "XOR" && $0.value.contains(xBase)
        })!
        let secondXOR = connections.first(where: {
            $0.value[1] == "XOR" && $0.value.contains(firstXOR.key)
        })
        if let secondXOR {
            if z != secondXOR.key {
                swaps.append([z, secondXOR.key])
            }
        } else {
            let withAND = connections.first(where: {
                ($0.key == c[0] || $0.key == c[2]) && $0.value[1] == "AND"
            })!
            swaps.append([withAND.key, firstXOR.key])
        }
    }

    var cloned = connections
    for keys in swaps {
        cloned[keys[0]] = connections[keys[1]]
        cloned[keys[1]] = connections[keys[0]]
    }

    let x = value(values: values, prefix: "x")
    let y = value(values: values, prefix: "y")
    let expected = values.count > 20 ? x + y : x & y
    let initial = simulate(values: values, connections: cloned)
    let z = value(values: initial, prefix: "z")
    assert(expected == z)
    return swaps.flatMap { $0 }.sorted().joined(separator: ",")
}

private func value(values: [String: Int], prefix: String) -> Int {
    values.filter { $0.key.starts(with: prefix) }
        .sorted { $0.key < $1.key }.map(\.value)
        .enumerated().map { $1 << $0 }.sum
}

private func simulate(values: [String: Int], connections: [String: [String]]) -> [String: Int] {
    var values = values
    var connections = connections
    let zs = Set(connections.keys.filter { $0.starts(with: "z") })
    while !Set(values.keys).isSuperset(of: zs) && !connections.isEmpty {
        var calculated = false
        for (k, op) in connections {
            if let lhs = values[op[0]],
                let rhs = values[op[2]]
            {
                let v =
                    switch op[1] {
                    case "AND": lhs == 1 ? rhs : 0
                    case "OR": lhs == 1 ? 1 : rhs
                    case "XOR": lhs ^ rhs
                    default: fatalError()
                    }
                values[k] = v
                connections.removeValue(forKey: k)
                calculated = true
            }
        }
        if !calculated {
            return values
        }
    }
    return values
}

public let day24 = Solution(
    name: "day24",
    part1: part1,
    part2: part2
)
