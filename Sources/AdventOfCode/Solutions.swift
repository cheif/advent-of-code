import Foundation

func day1(_ input: String) -> (Int, Int) {
    let depths: [Int] = input.decodeLines()
    return (depths.increases(), depths.windowed(size: 3).map(\.sum).increases())
}

func day2(_ input: String) -> (Int, Int) {
    enum Dir: String, StringDecodable {
        init?<S>(_ s: S) where S : StringProtocol {
            self.init(rawValue: String(s))
        }

        case up
        case down
        case forward
    }
    let directions: [(direction: Dir, amount: Int)] = input.decodeLines()
    let depth = directions.reduce(0) { acc, dir in
        switch dir.direction {
        case .up:
            return acc - dir.amount
        case .down:
            return acc + dir.amount
        case .forward:
            return acc
        }
    }
    let horizontal = directions.filter { $0.direction == .forward }.map(\.amount).sum
    let correctDepth = directions.reduce((depth: 0, aim: 0)) { acc, dir -> (depth: Int, aim: Int) in
        switch dir.direction {
        case .up:
            return (depth: acc.depth, aim: acc.aim - dir.amount)
        case .down:
            return (depth: acc.depth, aim: acc.aim + dir.amount)
        case .forward:
            return (depth: acc.depth + acc.aim * dir.amount, aim: acc.aim)
        }
    }.depth
    return (depth * horizontal, correctDepth * horizontal)
}

protocol StringDecodable {
    init?<S: StringProtocol>(_ s: S)
}

extension Int: StringDecodable {
    init?<S>(_ s: S) where S : StringProtocol {
        self.init(s, radix: 10)
    }
}

private extension String {
    func decodeLines<T>() -> [T] where T: StringDecodable {
        split(separator: "\n")
            .map { T($0)! }
    }

    func decodeLines<T, V>() -> [(T, V)] where T: StringDecodable, V: StringDecodable {
        split(separator: "\n")
            .map { str -> (T, V) in
                let split = str.split(separator: " ")
                return (T(split[0])!, V(split[1])!)
            }
    }
}

private extension Array where Element: Numeric, Element: Comparable {
    var sum: Element {
        reduce(.zero, +)
    }

    func windowed(size: Int) -> [[Element]] {
        reduce([[]]) { acc, curr -> [[Element]] in
            let last = acc.last ?? []
            if last.count == size {
                let next = Array(last.suffix(size - 1) + [curr])
                return acc + [next]
            } else {
                let next = last + [curr]
                return [next]
            }
        }
    }

    func increases() -> Element {
        let reduced = reduce((0, nil)) { acc, curr -> (Element, Element?) in
            let (total, prev) = acc
            if let prev = prev,
               prev < curr {
                return (total + 1, curr)
            } else {
                return (total, curr)
            }
        }
        return reduced.0
    }
}
