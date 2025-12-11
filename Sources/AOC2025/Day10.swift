import Algorithms
import Shared

private func part1(input: String) -> Int {
    let machines = input.split(whereSeparator: \.isNewline).map { line in
        let splits = line.split(separator: " ").filter { $0.contains("[") || $0.contains("(") }
        return (
            target: Array(splits[0].dropFirst().dropLast()),
            buttons: splits.dropFirst().map { s in
                s.dropFirst().dropLast().split(separator: ",").map { Int($0)! }
            }
        )
    }
    return machines.map(minPresses(machine:)).sum
}

private func part2(input: String) -> Int {
    let machines = input.split(whereSeparator: \.isNewline).map { line in
        let splits = line.split(separator: " ")
        return (
            lights: Array(splits[0].dropFirst().dropLast()),
            buttons: splits.dropFirst().dropLast().map { s in
                s.dropFirst().dropLast().split(separator: ",").map { Int($0)! }
            },
            joltages: splits.last!.dropFirst().dropLast().split(separator: ",").map { Int($0)! }
        )
    }
    // print("machines:", machines.count)
    return machines.map(minJoltagePresses(machine:)).sum
}

func minPresses(machine: (target: [Character], buttons: [[Int]])) -> Int {
    let start: [Character] = machine.target.map { _ in "." }
    let fastest = aStar(
        start: start,
        finished: { $0 == machine.target },
        estimatedCostToFinish: { _ in 1 },
        candidates: { state in
            machine.buttons.map { button in
                (state.press(button: button), 1)
            }
        }
    )
    return fastest?.dropFirst().count ?? 0
}

typealias Machine = (lights: [Character], buttons: [[Int]], joltages: [Int])
func minJoltagePresses(machine: Machine) -> Int {
    // let buttonsWithPossibleRanges = machine.buttons.map { button in
    //     let affectedJoltages = button.map { i in machine.joltages[i] }
    //     let maxPresses = affectedJoltages.max() ?? 0
    //     return (0...maxPresses, button)
    // }
    // print("machine:", machine)
    // print(buttonsWithPossibleRanges.map(\.0.count).reduce(1, *))
    let byJoltage = machine.joltages.indices.map { i in
        machine.buttons.enumerated().filter { $0.1.contains(i) }.map(\.element)
    }
    // print(byJoltage)
    struct State: Hashable {
        let joltage: [Int]
        let presses: Int
    }
    let fastest = aStar(
        start: State(joltage: machine.joltages.map { _ in 0 }, presses: 0),
        finished: { $0.joltage == machine.joltages },
        estimatedCostToFinish: { state in
            let diffs = zip(machine.joltages, state.joltage).map { $0 - $1 }
            return diffs.sum
        },
        candidates: { state in
            let firstMismatching = zip(machine.joltages, state.joltage).map { $0 - $1 }.enumerated()
                .first {
                    $0.element > 0
                }
            guard let firstMismatching else {
                return []
            }
            let buttons = byJoltage[firstMismatching.offset]
            let totalPresses = firstMismatching.element
            // print("Candidates")
            // print(totalPresses, buttons)
            let candidates = buttons.repeatedCombinations(ofCount: totalPresses)
            // print(firstMismatching)
            // print(candidates.count)
            return
                candidates
                .map { buttonPresses in
                    buttonPresses.reduce(state.joltage) { $0.press(button: $1) }
                }
                .filter { joltage in
                    let diffs = zip(machine.joltages, joltage).map { $0 - $1 }
                    return !diffs.contains(where: { $0 < 0 })
                }
                .map { joltage in
                    (State(joltage: joltage, presses: totalPresses), totalPresses)
                }
        }
    )
    return fastest?.map(\.presses).sum ?? 0
    /*
      3 5 4 7
    A 0 0 0 1
    B 0 1 0 1
    C 0 0 1 0
    D 0 0 1 1
    E 1 0 1 0
    F 1 1 0 0
    
    E + F = 3 => E = 3 - F
    B + F = 5 => F = 5 - B
    C + D + E = 4 => E = 4 - C - D
    A + B + D = 7 => B = 7 - A - D
    
    E = B - 2 = 7 - A - D - 2 = 5 - A - D
    4 - C - D = 5 - A - D
    4 - C = 5 - A
    C - 4 = A - 5
    C = A - 1
    A = C + 1
    
    */
    /*
    struct State: Hashable {
        let joltage: [Int]
        let presses: Int
        let button: Int
    }
    let start: [Int] = machine.joltages.map { _ in 0 }
    let startState = State(joltage: start, presses: 0, button: 0)
    let fastest = aStar(
        start: startState,
        finished: { $0.joltage == machine.joltages },
        estimatedCostToFinish: { state in
            buttonsWithPossibleRanges.count - state.button
        },
        log: { print($0) },
        candidates: { state -> [(State, Int)] in
            guard let (range, button) = buttonsWithPossibleRanges[safe: state.button] else {
                return []
            }
            return range.map { presses -> (State, Int) in
                let joltage = state.joltage.press(button: button, presses: presses)
                return (
                    State(
                        joltage: joltage, presses: state.presses + presses, button: state.button + 1
                    ), presses
                )
            }
            .filter { state, _ in
                let diffs = zip(machine.joltages, state.joltage).map { $0 - $1 }
                // print(state, diffs)
                return !diffs.contains(where: { $0 < 0 })
            }
        }
    )
    return fastest?.last?.presses ?? 0
    */
    // let mostPresses = machine.buttons.map(\.count).max() ?? 1
    // let fastest = aStar(
    //     start: start,
    //     finished: { $0 == machine.joltages },
    //     estimatedCostToFinish: { state in
    //         let diffs = zip(machine.joltages, state).map { $0 - $1 }
    //         return diffs.sum / mostPresses
    //     },
    //     log: { print($0) },
    //     candidates: { state -> [([Int], Int)] in
    //         return machine.buttons
    //             .map { button in
    //                 let singlePress = state.press(button: button)
    //                 return (singlePress, 1)
    //                 // let twoPresses = machine.buttons.map(singlePress.press(button:)).map { ($0, 2) }
    //                 // return [(singlePress, 1)] + twoPresses
    //             }
    //             .filter { state, _ in
    //                 let diffs = zip(machine.joltages, state).map { $0 - $1 }
    //                 // print(state, diffs)
    //                 return !diffs.contains(where: { $0 < 0 })
    //             }
    //     }
    // )
    // print(fastest?.dropFirst())
    // return fastest?.dropFirst().count ?? 0
}

extension [Character] {
    func press(button: [Int]) -> Self {
        var out = self
        for b in button {
            out[b] = out[b] == "." ? "#" : "."
        }
        return out
    }
}

extension RandomAccessCollection {
    func repeatedCombinations(ofCount count: Int) -> [[Element]] {
        guard count != 0, let first else {
            return [[]]
        }
        let head = [first]
        let subCombinations = self.repeatedCombinations(ofCount: count - 1)
        var ret = subCombinations.map { head + $0 }
        ret += self.dropFirst().repeatedCombinations(ofCount: count)
        // Why is this filter needed??
        return ret.filter { $0.count == count }
    }
}

extension [Int] {
    func press(button: [Int], presses: Int = 1) -> Self {
        var out = self
        for b in button {
            out[b] += presses
        }
        return out
    }
}

public let day10 = Solution(
    name: "day10",
    part1: part1,
    part2: part2
)
