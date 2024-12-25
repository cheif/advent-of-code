import Shared

private func part1(input: String) -> String {
    let split = input.split(separator: "\n\n")
    var values = Dictionary(uniqueKeysWithValues: split[0].split(whereSeparator: \.isNewline).map { l in 
        let s = l.split(separator: ": ")
        return (String(s[0]), Int(s[1])!)
    })
    let connections = Dictionary(uniqueKeysWithValues: split[1].split(whereSeparator: \.isNewline).map { l in
        let s = l.split(separator: " -> ")
        return (String(s[1]), s[0].split(separator: " ").map { String($0) })
    })
    values = simulate(values: values, connections: connections)
    let zVals = values.filter { $0.key.starts(with: "z") }.sorted { $0.key < $1.key }.map(\.value)
    return "\(zVals.enumerated().map { off, v in v << off }.sum)"
}

private func part2(input: String) -> String {
    let split = input.split(separator: "\n\n")
    var values = Dictionary(uniqueKeysWithValues: split[0].split(whereSeparator: \.isNewline).map { l in 
        let s = l.split(separator: ": ")
        return (String(s[0]), Int(s[1])!)
    })
    let connections = Dictionary(uniqueKeysWithValues: split[1].split(whereSeparator: \.isNewline).map { l in
        let s = l.split(separator: " -> ")
        return (String(s[1]), s[0].split(separator: " ").map { String($0) })
    })

    let x = value(values: values, prefix: "x")
    let y = value(values: values, prefix: "y")
    let expected = values.count > 20 ? x + y : x & y
    let initial = simulate(values: values, connections: connections)
    print(expected)
    let initialZ = value(values: initial, prefix: "z")
    let expectedBits = String(expected, radix: 2).map { $0 }
    let actualBits = String(initialZ, radix: 2).map { $0 }
    print(String(expected, radix: 2))
    print(String(initialZ, radix: 2))

    let diffs = initial.filter({ $0.key.starts(with: "z") })
        .sorted(by: { $0.key < $1.key })
        .map { key, v in 
            let idx = Int(key.dropFirst())!
            return (key: key, value: v, expected: Int(String(expectedBits.reversed()[idx]))!)
        }
    let incorrect = diffs.filter { $0.value != $0.expected }.map(\.key)
    for d in diffs {
        print(d)
    }
    let correct = Set(connections.keys.filter { $0.starts(with: "z") })
        .filter { !incorrect.contains($0) }

    let affectsIncorrect = Set(connections.keys
        .filter { k in
            incorrect.contains { inc in
                isInPath(connections: connections, k: k, of: inc) 
            }
        }
    )
    let affectsCorrect = Set(connections.keys
        .filter { k in
            correct.contains { inc in
                isInPath(connections: connections, k: k, of: inc, recurse: true) 
            }
        }
    )

    print(incorrect)
    print(affectsIncorrect)
    print(affectsCorrect)
    let validSwaps = affectsIncorrect.union(incorrect).subtracting(affectsCorrect)
    print(validSwaps)
    let pairs = Array(validSwaps.combinations(ofCount: 2))

    /*
    let pairs = Array(Set(connections.keys.combinations(ofCount: 2)))
        .filter { pair in 
            affectsIncorrect.contains(pair[0]) ||
            affectsIncorrect.contains(pair[1]) && !(
                affectsCorrect.contains(pair[0]) ||
                affectsCorrect.contains(pair[1])
            )
        }
    */
    print(pairs.count)
    let noPairs = values.count > 20 ? 4 : 2

    let swaps = pairs.combinations(ofCount: noPairs)
        //.filter { pairs in 
        //    Set(pairs.flatMap { $0 }).count == noPairs * 2
        //}
        //.filter { $0.map { Set($0) }.contains(Set(["z00", "z05"])) }
    print(swaps.count)
    let valid = swaps
        .enumerated()
        .first { idx, pairs in 
            if idx % 1000 == 0 {
                print("at", idx)
            }
            //print("testing", pairs)
            var cloned = connections
            for keys in pairs {
                cloned[keys[0]] = connections[keys[1]]
                cloned[keys[1]] = connections[keys[0]]
            }
            //print("run")
            let res = simulate(values: values, connections: cloned)
            //print(res)
            return value(values: res, prefix: "y") == expected
        }
    return valid?.element.flatMap { $0 }.sorted().joined(separator: ",") ?? ""
}

private func isInPath(connections: [String: [String]], k: String, of: String, recurse: Bool = false) -> Bool {
    let downstream = connections.filter { $0.value.contains(k) }
    if downstream.contains(where: { key, _ in key == of }) {
        return true
    }
    guard recurse else {
        return false
    }
    return downstream.contains { key, _ in
        isInPath(connections: connections, k: key, of: of, recurse: recurse)
    }
}

private func isValid(values: [String: Int]) -> Bool {
    let x = values.filter { $0.key.starts(with: "x") }
        .sorted { $0.key < $1.key }.map(\.value)
        .enumerated().map { $1 << $0 }.sum
    let y = values.filter { $0.key.starts(with: "y") }
        .sorted { $0.key < $1.key }.map(\.value)
        .enumerated().map { $1 << $0 }.sum
    let z = values.filter { $0.key.starts(with: "z") }
        .sorted { $0.key < $1.key }.map(\.value)
        .enumerated().map { $1 << $0 }.sum
    return (x + y) == z
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
                let rhs = values[op[2]] {
                let v = switch op[1] {
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
