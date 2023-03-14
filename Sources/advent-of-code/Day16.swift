public func day16() {
    // 1577 is too low
//    print(part1(input: input))
    // 2324 is too low
    // 3269 isn't correct
    // 3853
    print(part2(input: input))
}

private func part1(input: String) -> Int {
    let valves = parse(input)
    let start = valves.first(where: { $0.id == "AA" })!
    let graph = Graph(valves: valves, start: start)

    struct State: Hashable, CustomDebugStringConvertible {
        let minute: Int
        let pressureReleased: Int
        let openValves: [Valve]
        let position: Valve

        var totalPressureReleased: Int {
            pressureReleased + flowRate * (30 - minute)
        }

        var flowRate: Int {
            openValves.map(\.flowRate).sum
        }

        var debugDescription: String {
            return "== Minute \(minute) ==\n Valves \(openValves.map(\.id).joined(separator: ",")) are open, releasing \(flowRate) pressure\ntotalPressureReleased: \(totalPressureReleased)"
        }

        func candidates(in graph: Graph<Valve>) -> [Self] {
            let edges = graph.edges
                .filter { $0.from == position }
                .filter { !openValves.contains($0.to) }
                .filter { $0.to.flowRate > 0 }
                .filter { $0.weight < (30 - minute - 1) }
            return edges.map { edge in
                State(
                    minute: minute + edge.weight + 1,
                    pressureReleased: pressureReleased + flowRate * (edge.weight + 1),
                    openValves: openValves + [edge.to],
                    position: edge.to
                )
            }
        }
    }

    let initial = State(minute: 0, pressureReleased: 0, openValves: [], position: start)
    let maximized = maximizeRecursive(initial, finished: { $0.minute >= 30 }, score: \.totalPressureReleased) { state in
        state.candidates(in: graph)
    }
    for state in maximized {
        print(state)
    }
    let lastState = maximized.last!
    return lastState.totalPressureReleased
}

private func part2(input: String) -> Int {
    let valves = parse(input)
    let start = valves.first(where: { $0.id == "AA" })!
    let graph = Graph(valves: valves, start: start)

    struct State: Hashable, CustomDebugStringConvertible {
        let minute: Int
        let openValves: Set<Valve>
        let totalPressureReleased: Int

        struct Position: Hashable, CustomDebugStringConvertible {
            let timeToGo: Int
            let destination: Valve

            var debugDescription: String {
                "Position(timeToGo: \(timeToGo), destination: \(destination.id))"
            }
        }
        let positions: [Position]

        var flowRate: Int {
            openValves.map(\.flowRate).sum
        }

        func maximumPotentialPressureReleased(maximumFlowRate: Int) -> Int {
            return totalPressureReleased + maximumFlowRate * (26 - minute)
        }

        var debugDescription: String {
            return "== Minute \(minute) ==\n Valves \(openValves.map(\.id).sorted().joined(separator: ", ")) are open, releasing \(flowRate) pressure\n\(positions), totalPressureReleased: \(totalPressureReleased)"
        }

        func candidates(in graph: Graph<Valve>) -> [Self] {
            let newPositions = positions.map { position in
                guard position.timeToGo == 0 else {
                    return [Position(
                        timeToGo: position.timeToGo - 1,
                        destination: position.destination
                    )]
                }
                // Someone is standing still at this valve, and has done so for a minute (AKA it's opened), and it's time to go
                let edges = graph.edges
                    .filter { $0.from == position.destination }
                    // It's not open yet
                    .filter { !openValves.contains($0.to) }
                    // No one is on their way to open it
                    .filter { !positions.map(\.destination).contains($0.to) }
                    .filter { $0.to.flowRate > 0 }
                    .filter { $0.weight < (26 - minute) }

                // Nowhere to go, just stand still
                guard !edges.isEmpty else {
                    return [Position(
                        timeToGo: position.timeToGo - 1,
                        destination: position.destination
                    )]
                }

                return edges.map { edge in
                    Position(timeToGo: edge.weight, destination: edge.to)
                }
            }

            let openedValves = positions
                .filter { $0.timeToGo == 0 && $0.destination.flowRate > 0 }
                .map(\.destination)
            let pressureReleased = openedValves.map(\.flowRate).sum * (26 - minute)

            let combinations = newPositions[0].flatMap { lhs in
                newPositions[1].filter({ $0.destination != lhs.destination }).map { rhs in
                    [lhs, rhs]
                }
            }
            return combinations
                .map { positions in
                    State(
                        minute: minute + 1,
                        openValves: openValves.union(openedValves),
                        totalPressureReleased: totalPressureReleased + pressureReleased,
                        positions: positions.sorted(by: { $0.hashValue < $1.hashValue })
                    )
            }
        }
    }

    let initial = State(minute: 0, openValves: [], totalPressureReleased: 0, positions: [
        .init(timeToGo: 0, destination: start),
        .init(timeToGo: 0, destination: start)
    ])
    let maximumFlowRate = valves.map(\.flowRate).sum
    let maximized = maximizeIterative(
        initial,
        finished: { $0.minute == 26 },
        score: \.totalPressureReleased,
        maximumPotentialScore: { $0.maximumPotentialPressureReleased(maximumFlowRate: maximumFlowRate) }
    ) { state in
        return state.candidates(in: graph)
    }
    for state in maximized {
        print(state)
    }
    let lastState = maximized.last!
    return lastState.totalPressureReleased
}

private func parse(_ input: String) -> [Valve] {
    input.split(whereSeparator: \.isNewline)
        .map { line in
            let name = String(line.dropFirst(6).split(whereSeparator: \.isWhitespace)[0])
            let flowRate = Int(String(line.split(separator: "=")[1].split(separator: ";")[0]))!
            let destinations = line.split(separator: "valv")[1].split(maxSplits: 1, whereSeparator: \.isWhitespace)[1].split(separator: ", ").map { String($0) }
            return Valve(name: name, flowRate: flowRate, destinations: destinations)
        }
}

private struct Valve: Identifiable, Hashable, CustomDebugStringConvertible {
    let name: String
    let flowRate: Int
    let destinations: [String]

    var id: String { name }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var debugDescription: String {
        "Valve(name: \(name), flowRate: \(flowRate))"
    }
}

private func reconstructPath(cameFrom: [Valve: Valve], current: Valve) -> [Valve] {
    var current = current
    var path = [current]
    while cameFrom.keys.contains(current) {
        current = cameFrom[current]!
        path.insert(current, at: 0)
    }
    return path
}

private func aStar(
    start: Valve,
    end: Valve,
    valves: [Valve]
) -> [Valve]? {
    var open = Set([start])
    var cameFrom: [Valve: Valve] = [:]
    var gScore: [Valve: Int] = [start: 0]
    var fScore: [Valve: Int] = [start: 100]

    while !open.isEmpty {
        let current = open.sorted { fScore[$0]! < fScore[$1]! }.first!
        open.remove(current)
        if current == end {
            return reconstructPath(cameFrom: cameFrom, current: current)
        }
        let neighbours = valves.filter { current.destinations.contains($0.id) }
        for neighbour in neighbours {
            let tentativeGScore = gScore[current]! + 1
            if let current = gScore[neighbour],
               current <= tentativeGScore {
                // Current is better, do nothing
                continue
            } else {
                cameFrom[neighbour] = current
                gScore[neighbour] = tentativeGScore
                fScore[neighbour] = tentativeGScore + 100
                open.insert(neighbour)
            }
        }
    }
    return nil
}

private extension Graph where T == Valve {
    init(valves: [Valve], start: Valve) {
        let valvesWithFlow = valves.filter { $0.flowRate > 0 || $0 == start }
        self.edges = valvesWithFlow.flatMap { from in
            valvesWithFlow.filter { $0 != from }.map { to in
                let shortestPath = aStar(start: from, end: to, valves: valves)
                return Edge(from: from, to: to, weight: shortestPath!.count - 1)
            }
        }
    }
}

private let test = """
Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
Valve BB has flow rate=13; tunnels lead to valves CC, AA
Valve CC has flow rate=2; tunnels lead to valves DD, BB
Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
Valve EE has flow rate=3; tunnels lead to valves FF, DD
Valve FF has flow rate=0; tunnels lead to valves EE, GG
Valve GG has flow rate=0; tunnels lead to valves FF, HH
Valve HH has flow rate=22; tunnel leads to valve GG
Valve II has flow rate=0; tunnels lead to valves AA, JJ
Valve JJ has flow rate=21; tunnel leads to valve II
"""

private let input = """
Valve TU has flow rate=0; tunnels lead to valves XG, ID
Valve RR has flow rate=0; tunnels lead to valves BO, NF
Valve UB has flow rate=0; tunnels lead to valves GY, AC
Valve OP has flow rate=0; tunnels lead to valves OU, DI
Valve KL has flow rate=21; tunnels lead to valves QZ, QT
Valve QA has flow rate=0; tunnels lead to valves AC, XM
Valve CI has flow rate=0; tunnels lead to valves RH, BC
Valve NZ has flow rate=0; tunnels lead to valves TO, OU
Valve MY has flow rate=0; tunnels lead to valves BO, KV
Valve GY has flow rate=0; tunnels lead to valves KW, UB
Valve ZB has flow rate=0; tunnels lead to valves YS, XH
Valve OU has flow rate=8; tunnels lead to valves ZV, YA, NZ, OP
Valve KV has flow rate=0; tunnels lead to valves MJ, MY
Valve BC has flow rate=0; tunnels lead to valves TO, CI
Valve YS has flow rate=22; tunnels lead to valves ZB, UE
Valve CD has flow rate=25; tunnels lead to valves LS, FO
Valve ID has flow rate=11; tunnels lead to valves BI, TU
Valve RN has flow rate=0; tunnels lead to valves AC, CN
Valve HH has flow rate=0; tunnels lead to valves GI, KW
Valve QZ has flow rate=0; tunnels lead to valves AC, KL
Valve BI has flow rate=0; tunnels lead to valves OI, ID
Valve NF has flow rate=0; tunnels lead to valves RR, OI
Valve CH has flow rate=0; tunnels lead to valves AA, MJ
Valve UE has flow rate=0; tunnels lead to valves LS, YS
Valve ZV has flow rate=0; tunnels lead to valves OU, AA
Valve YM has flow rate=0; tunnels lead to valves OI, AA
Valve IG has flow rate=0; tunnels lead to valves TO, QL
Valve FO has flow rate=0; tunnels lead to valves CD, KW
Valve AC has flow rate=4; tunnels lead to valves KC, RN, QA, QZ, UB
Valve JO has flow rate=0; tunnels lead to valves RH, DI
Valve OI has flow rate=10; tunnels lead to valves VS, BI, CN, NF, YM
Valve MJ has flow rate=3; tunnels lead to valves KV, XM, ER, CH, BS
Valve KC has flow rate=0; tunnels lead to valves AC, AA
Valve ER has flow rate=0; tunnels lead to valves MJ, VS
Valve CV has flow rate=0; tunnels lead to valves TO, IU
Valve RW has flow rate=0; tunnels lead to valves DT, QT
Valve CN has flow rate=0; tunnels lead to valves OI, RN
Valve IU has flow rate=0; tunnels lead to valves DY, CV
Valve LS has flow rate=0; tunnels lead to valves CD, UE
Valve AA has flow rate=0; tunnels lead to valves CH, KC, YM, ZV, GI
Valve DY has flow rate=23; tunnels lead to valves IU, ZP
Valve BS has flow rate=0; tunnels lead to valves MJ, KW
Valve XG has flow rate=0; tunnels lead to valves TU, BO
Valve RH has flow rate=15; tunnels lead to valves HK, JO, CI
Valve BO has flow rate=18; tunnels lead to valves MY, XG, RR
Valve YA has flow rate=0; tunnels lead to valves OU, HK
Valve VS has flow rate=0; tunnels lead to valves OI, ER
Valve KW has flow rate=6; tunnels lead to valves BS, XH, GY, HH, FO
Valve XH has flow rate=0; tunnels lead to valves ZB, KW
Valve ZP has flow rate=0; tunnels lead to valves DY, DI
Valve QL has flow rate=0; tunnels lead to valves DI, IG
Valve GI has flow rate=0; tunnels lead to valves HH, AA
Valve DT has flow rate=24; tunnel leads to valve RW
Valve DI has flow rate=13; tunnels lead to valves OP, ZP, JO, QL
Valve QT has flow rate=0; tunnels lead to valves RW, KL
Valve XM has flow rate=0; tunnels lead to valves QA, MJ
Valve HK has flow rate=0; tunnels lead to valves RH, YA
Valve TO has flow rate=19; tunnels lead to valves NZ, IG, BC, CV
"""
