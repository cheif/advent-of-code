import Algorithms
import Shared

private func part1(input: String) -> Int {
    let computer = Assembunny(input: input)
    let lowestLooping = (0...).first { a in 
        return computer.loopingOnesAndZeroes(a: a)
    }
    // 90 is incorrect
    return lowestLooping ?? 0
}

private func part2(input: String) -> Int {
    return 0
}

extension Assembunny {
    fileprivate func loopingOnesAndZeroes(a: Int) -> Bool {
        var registers = [
            "a": a,
            "b": 0,
            "c": 0,
            "d": 0,
        ]
        var output: [Int] = []
        var successful = false
        registers = self.run(registers: registers) { val in
            output.append(val)
            if output.count.isMultiple(of: 2),
                !output.chunks(ofCount: 2).allSatisfy({ $0.first == 0 && $0.last == 1 })
            {
                // Halt
                return true
            } else if output.count > 100 {
                // We found success!
                successful = true
                return true
            }

            return false
        }
        return successful
    }
}

public let day25 = Solution(
    name: "day25",
    part1: part1,
    part2: part2
)
