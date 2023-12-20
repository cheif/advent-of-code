import Foundation
import Shared

private enum Pulse: CustomDebugStringConvertible {
    case high
    case low

    var debugDescription: String {
        switch self {
        case .high: return ".high"
        case .low: return ".low"
        }
    }
}

private typealias State = Pulse
extension State {
    func flip() -> State {
        switch self {
        case .low: return .high
        case .high: return .low
        }
    }
}

private struct Module {
    let name: String
    var type: `Type`
    let destinations: [String]

    enum `Type`: Equatable, CustomDebugStringConvertible {
        case button
        case broadcast
        case flipFlop(state: State)
        case conjunction(states: [String: State])

        var debugDescription: String {
            switch self {
            case .button: return ".button"
            case .broadcast: return ".broadcast"
            case .flipFlop(let state): return ".flipFlop(\(state))"
            case .conjunction(let states): return ".conjunction(\(states.sorted(by: { $0.key < $1.key })))"
            }
        }
    }

    mutating func receive(pulse: Pulse, from: Module) -> [(Pulse, String)] {
        switch type {
        case .button:
            return []
        case .broadcast:
            return destinations.map { (pulse, $0) }
        case .flipFlop(let state):
            switch (pulse, state) {
            case (.high, _):
                return []
            case (.low, let state):
                let flipped = state.flip()
                self.type = .flipFlop(state: flipped)
                return destinations.map { (flipped, $0) }
            }
        case .conjunction(var states):
            states[from.name] = pulse
            self.type = .conjunction(states: states)
            let toSend: Pulse = states.allSatisfy { $0.value == .high } ? .low : .high
            return destinations.map { (toSend, $0) }
        }
    }

    static func parse(input: String) -> [String: Module] {
        let splitted = input.split(whereSeparator: \.isNewline)
            .map { line in
                let split = line.split(separator: " -> ")
                let name = String(split[0].drop(while: { $0 == "%" || $0 == "&" }))
                return (split[0].first!, name: name, destinations: split[1].split(separator: ", ").map(String.init))
            }
        return splitted
            .map { typeSpec, name, destinations in
                let inputs = splitted
                    .filter { $0.destinations.contains(name) }
                    .map(\.name)
                let type: Module.`Type` = switch typeSpec {
                case "%": .flipFlop(state: .low)
                case "&": .conjunction(states: Dictionary(uniqueKeysWithValues: inputs.map { ($0, .low) }))
                default: .broadcast
                }
                return Module(
                    name: name,
                    type: type,
                    destinations: destinations
                )
            }
            .grouped(by: \.name)
            .mapValues { $0.first! }
    }
}

private typealias Signal = (pulse: Pulse, destination: String, source: Module)
private func getSentPulses(modules: inout [String: Module], startSignal: Signal) -> [Pulse: Int] {
    var sent: [Pulse: Int] = [
        .low: 0,
        .high: 0,
    ]
    var outstanding: [(pulse: Pulse, destination: String, source: Module)] = [startSignal]
    while !outstanding.isEmpty {
        let next = outstanding.removeFirst()
        sent[next.pulse]! += 1
        if var destination = modules[next.destination] {
            outstanding += destination.receive(pulse: next.pulse, from: next.source).map { ($0, $1, destination) }
            modules[next.destination] = destination
        }
    }
    return sent
}

private func getEmittedSignals(modules: inout [String: Module], startSignal: Signal) -> [Signal] {
    var emitted: [Signal] = []
    var outstanding: [Signal] = [startSignal]
    while !outstanding.isEmpty {
        let next = outstanding.removeFirst()
        if var destination = modules[next.destination] {
            let signals = destination.receive(pulse: next.pulse, from: next.source).map { ($0, $1, destination) }
            outstanding += signals
            emitted += signals
            modules[next.destination] = destination
        }
    }
    return emitted
}

public let day20 = Solution(
    part1: { input in
        var modules = Module.parse(input: input)
        let button = Module(name: "button", type: .button, destinations: ["broadcaster"])
        let sent = (0..<1000).map { _ in getSentPulses(modules: &modules, startSignal: (.low, "broadcaster", button)) }
        let counts = sent.reduce(into: [Pulse.low: 0, Pulse.high: 0]) { acc, sent in
            acc[.low]! += sent[.low]!
            acc[.high]! += sent[.high]!
        }
        return counts[.low]! * counts[.high]!
    },
    part2: { input in
        var modules = Module.parse(input: input)

        let modulesConnectedToRx = modules.filter { $0.value.destinations.contains("rx") }.map(\.key)
        let upstreamToRx = modules.filter { _, val in val.destinations.contains(where: { modulesConnectedToRx.contains($0) }) }.map(\.key)
        var firstHighSeen: [String: Int] = [:]

        let button = Module(name: "button", type: .button, destinations: ["broadcaster"])
        var outstanding: [(pulse: Pulse, destination: String, source: Module)] = []
        var presses = 0
        while upstreamToRx.count != firstHighSeen.count {
            presses += 1
            let emitted = getEmittedSignals(modules: &modules, startSignal: (.low, "broadcaster", button))
            if let signal = emitted.first(where: { $0.pulse == .high && upstreamToRx.contains($0.source.name) }),
               firstHighSeen[signal.source.name] == nil {
                firstHighSeen[signal.source.name] = presses
            }
        }
        return firstHighSeen.map(\.value).leastCommonMultiple()
    },
    testResult: (32000000, 0),
    testInput: #"""
broadcaster -> a, b, c
%a -> b
%b -> c
%c -> inv
&inv -> a
"""#,
    input: #"""
%vn -> ts, lq
&ks -> dt
%zt -> vl
%xg -> ts, pb
&xd -> qz, bc, zt, vk, hq, qx, gc
&pm -> dt
%gb -> vj, xd
%qx -> gb
%rl -> qn
%lq -> gk
%qm -> bf
%zn -> vh, pf
%lz -> kk, vr
%bf -> rr
%gx -> vr
%zr -> vx, pf
%lt -> ng, vr
%hd -> mg, xd
%mg -> xd
%tx -> jg, vr
%gk -> kx, ts
&vr -> tr, vf, tx, ks, kk, jg
broadcaster -> qz, tx, jr, hk
%bc -> qx
%xz -> lt, vr
%jg -> sb
%qn -> zr, pf
%gc -> xv
%vx -> lj, pf
%vf -> cn
&dt -> rx
%sb -> lz, vr
%kx -> xg
%hk -> pf, tv
%cb -> pf
&dl -> dt
%vl -> xd, bc
%fl -> pp, pf
%ng -> vr, gx
%jr -> ts, qm
%cd -> vn, ts
%mt -> ts
%rr -> ts, cd
%tr -> xz
%hq -> zt
%xv -> hq, xd
%vj -> xd, hd
%pp -> zn
%vh -> pf, cb
%cn -> vr, tr
%kk -> vf
&pf -> pp, tv, rl, pm, hk
&ts -> dl, qm, kx, lq, bf, jr
%tv -> rl
&vk -> dt
%pb -> ts, mt
%lj -> pf, fl
%qz -> xd, gc
"""#
)

