import Shared

private func part1(input: String) -> Int {
    let machines = parse(input: input)
    let cheapestWins = machines.compactMap(costToWin(machine:))
    return cheapestWins.sum
}

private func part2(input: String) -> Int {
    let machines = parse(input: input)
    let corrected = machines.map { m -> Machine in 
        return (
            a: m.a, 
            b: m.b, 
            prize: m.prize
                .move(in: .right, step: 10000000000000)
                .move(in: .down, step: 10000000000000)
        )
    }
    let cheapestWins = corrected.compactMap(costToWin(machine:))
    return cheapestWins.sum
}
/*
a*94 + b*22 == 8400
a*94 = 8400 - b*22
a = (8400 - b*22)/94

a*34 + b*67 == 5400
a*34 = 5400 - b*67
a = (5400 - b*67)/34


b*67 == 5400 - a*34
b = (5400 - a*34)/67
b = 5400/67 - a*34/67

===
a = 8400/94 - 5400/67*22/94 + a*34/67*22/94
a (1 - 34/67*22/94) = 8400/94 - 5400/67*22/94
a = (8400/94 - 5400/67*22/94)/(1 - 34/67*22/94) 
a = (8400 - 5400/67*22)/94/(1 - 34/67*22/94) 
a = (8400 * 67 - 5400*22)/67/(94 - 34/67*22) 
a = (8400 * 67 - 5400*22)/(94*67 - 34*22) 

8400 = 94a + 22b
5400 = 34a + 67b

=== generalized
a = (prize.x*bBut.dy - prize.y*bBut.dx)/(aBut.dx*bBut.dy - aBut.dy*bBut.dx)
*/

private func costToWin(machine: Machine) -> Int? {
    let divend = machine.prize.x*machine.b.y - machine.prize.y*machine.b.x
    let divider = machine.a.x*machine.b.y - machine.a.y*machine.b.x
    let a = divend/divider
    let b = Int((Double(machine.prize.y) - Double(a)*Double(machine.a.y))/Double(machine.b.y))
    let isValid = (machine.a.x * a + machine.b.x * b == machine.prize.x) &&
        (machine.a.y * a + machine.b.y * b == machine.prize.y)
    return isValid ? (a*3 + b) : nil
}

private typealias Machine = (a: Position, b: Position, prize: Position)
private func parse(input: String) -> [Machine] {
    return input.split(separator: "\n\n").map { sub in 
        let lines = sub.split(whereSeparator: \.isNewline)
        let a = lines[0].split(separator: "X+")[1].split(separator: ", Y+").map { Int($0)! }
        let b = lines[1].split(separator: "X+")[1].split(separator: ", Y+").map { Int($0)! }
        let prize = lines[2].split(separator: "X=")[1].split(separator: ", Y=").map { Int($0)! }
        return (
            a: Position(x: a[0], y: a[1]),
            b: Position(x: b[0], y: b[1]),
            prize: Position(x: prize[0], y: prize[1])
        )
    }
}

public let day13 = Solution(
    name: "day13",
    part1: part1,
    part2: part2
)
