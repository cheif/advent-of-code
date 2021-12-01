import Foundation

func day1(_ input: String) -> (Int, Int) {
    let depths = input.split(separator: "\n").map { Int($0)! }
    return (depths.increases(), depths.windowed(size: 3).map(\.sum).increases())
}

private func increases(in input: [Int]) -> Int {
    let reduced = input.reduce((0, nil)) { acc, curr -> (Int, Int?) in
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
