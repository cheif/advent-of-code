import Algorithms
import Shared

private func part1(input: String) -> Int {
    let nodes = parse(input: input)
    let viable = nodes.keys.combinations(ofCount: 2).filter { pair in
        let a = pair[0]
        let b = pair[1]
        return isViable(a: a, b: b) || isViable(a: b, b: a)
    }
    // 98 is not correct
    return viable.count
}

private func part2(input: String) -> Int {
    let nodes = parse(input: input)

    let goal = Position(x: 0, y: 0)
    let dataNode =
        nodes
        .filter { $0.value.y == 0 }
        .max(by: { $0.value.x < $1.value.x })!
        .key

    struct State: Hashable, CustomStringConvertible {
        var nodes: [Node: Position]
        let steps: Int
        var description: String {
            let yRange = nodes.map(\.value.y).range()
            return yRange.map { y in
                nodes
                    .filter { $0.value.y == y }
                    .sorted(by: { $0.value.x < $1.value.x })
                    .map(\.key.description)
                    .joined(separator: " -- ")
            }.joined(separator: "\n")
        }
    }

    let initial = State(nodes: nodes, steps: 0)

    let viableSwaps = nodes.keys.combinations(ofCount: 2)
        .filter { pair in
            let a = pair[0]
            let b = pair[1]
            return isViable(a: a, b: b) || isViable(a: b, b: a)
        }
    let viable: [Node: Set<Node>] = Dictionary(
        uniqueKeysWithValues: nodes.keys.map { node in
            let other =
                viableSwaps
                .filter { $0.contains(node) }
                .flatMap { $0 }
                .filter { $0 != node }
            return (node, Set(other))
        })
    let emptyNode = viable[dataNode]!.first!

    let best = aStar(start: initial) { state in
        state.nodes[dataNode] == goal
    } estimatedCostToFinish: { state in
        state.nodes[dataNode]!.distance(to: goal) + state.nodes[emptyNode]!.distance(to: goal)
    } log: {
        print($0)
    } candidates: { state in
        return possibleSwaps(nodes: state.nodes, viable: viable)
            .map { swap -> [Node: Position] in
                var new = state.nodes
                let pos = new[swap.b]!
                new[swap.b] = new[swap.a]!
                new[swap.a] = pos
                return new
            }
            .map { nodes -> (State, Int) in
                let state = State(nodes: nodes, steps: state.steps)
                return (state, 1)
            }
    }
    return best?.dropFirst().count ?? 0
}

private struct Swap: Hashable {
    let a: Node
    let b: Node
}

private func possibleSwaps(nodes: [Node: Position], viable: [Node: Set<Node>]) -> Set<Swap> {
    let all = nodes.flatMap { node, position in
        let swappable = viable[node]!
        return
            swappable
            .filter { nodes[$0]!.distance(to: position) == 1 }
            .map {
                node.name < $0.name ? Swap(a: node, b: $0) : Swap(a: $0, b: node)
            }
    }
    return Set(all)
}

private struct Node: Hashable, CustomStringConvertible {
    let name: String
    let used: Int
    let avail: Int

    var description: String {
        "\(used)T/\(used+avail)T"
    }
}
private func parse(input: String) -> [Node: Position] {
    let withPosition = input.split(whereSeparator: \.isNewline).dropFirst(2).map {
        line -> (Node, Position) in
        let s = line.split(whereSeparator: \.isWhitespace)
        let coordinates = s[0].dropFirst(16).split(separator: "-y").map { Int($0)! }
        let data = s.dropFirst().map { Int($0.dropLast())! }
        return (
            Node(name: String(s[0]), used: data[1], avail: data[2]),
            Position(x: coordinates[0], y: coordinates[1])
        )
    }
    return Dictionary(uniqueKeysWithValues: withPosition)
}

private func isViable(a: Node, b: Node) -> Bool {
    a.used > 0 && a != b && a.used <= b.avail
}

public let day22 = Solution(
    name: "day22",
    part1: part1,
    part2: part2
)
