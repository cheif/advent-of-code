import Foundation

public func day25() {
    print(part1(input: input))
//    print(part2(input: test))
}

private func part1(input: String) -> String {
    let numbers: [(snafu: Substring, decimal: Int)] = input
        .split(whereSeparator: \.isNewline)
        .map { snafu in (snafu, from(snafu: snafu)) }
    print(" SNAFU  Decimal")
    for number in numbers {
        print(
            number.snafu.padding(toLength: 7, withPad: " ", startingAt: 0),
            "\(number.decimal)"
        )
    }
    print(numbers.map(\.decimal).sum)
    return from(decimal: numbers.map(\.decimal).sum)
}

private func part2(input: String) -> Int {
    return 0
}

private let snafuMap: [Character: Int] = [
    "2": 2,
    "1": 1,
    "0": 0,
    "-": -1,
    "=": -2
]
private func from<S: StringProtocol>(snafu: S) -> Int {
    snafu
        .map { snafuMap[$0]! }
        .reversed()
        .enumerated()
        .map { index, value in Int(pow(5, Double(index))) * value }
        .sum
}

private func from(decimal: Int) -> String {
    var snafu = ""
    var iterations = 0
    var padding = 25
    while from(snafu: snafu) != decimal {
        iterations += 1
        if iterations > 100 {
            fatalError()
        }
        let diff = decimal - from(snafu: snafu)
        let paddingRange = snafu.isEmpty ? (0...padding) : (padding...padding)
        let candidates = paddingRange
            .flatMap { padding in
                snafuMap.keys.map { String($0).padding(toLength: padding, withPad: "0", startingAt: 0) }
            }
            .map { (snafu: $0, decimal: from(snafu: $0)) }
        guard let closestSnafu = candidates.min(by: { abs(diff - $0.decimal) < abs(diff - $1.decimal) }) else {
            fatalError()
        }
        if snafu.isEmpty {
            snafu = closestSnafu.snafu
        } else {
            let start = snafu.count - closestSnafu.snafu.count
            let range = snafu.index(snafu.startIndex, offsetBy: start)..<snafu.endIndex
            snafu.replaceSubrange(range, with: closestSnafu.snafu)
        }
        padding = closestSnafu.snafu.count - 1
        print("Snafu: \(snafu), decimal: \(from(snafu: snafu))")
    }

    return snafu
}

extension Dictionary where Value: Hashable {
    func swapKeyValues() -> Dictionary<Value, Key> {
        Dictionary<Value, Key>(uniqueKeysWithValues: lazy.map { ($0.value, $0.key) })
    }
}

private let test = """
1=-0-2
12111
2=0=
21
2=01
111
20012
112
1=-1=
1-12
12
1=
122
"""

private let input = """
21211-122
1=--02-10=-=00=-0
1=-2
1-1-1-===2=0--1-
1211=
1=22=-=
1-0-=0210
2-0-02
1=1--1=-0210---=-1
200-0=02--2
20112=02
1201--=-022
1-100==
1-
1=-1=22===200101-2
1==0010221-=22--0-02
1002=11022
1=02
222=---112-=21=02=
21==10--=01-1-=1
1===--11=102
2==2=0022=1=102
101221=-2-=-00-12
10=12220==---
1-2
2--01112
11=01-=1002-
1==-00-=10
10=2==-=
10-1=-=20-2-=
1=1
2120-
2-2-=-0==-
1-2-22=001-=-000
21222-2222=102-2--
101010
1=0110
1-21
10
1=022==2-
102-21==010
20=-2-
1==-==
1=-0212===101
111202220=12-1-=-2
1-11110-==0=0-0=2
2=2-0=0=02-2=-0-0=0
10=22=11-1-1-21-021
1212
20=1=00202-==2--
1==2
100--
122=-
2=220010
202-222=212100-110
20021=222==1--==-=
1==2212=-
1=-11--221===1==
21=21021-=1
2-
11=02-=-----1=0=
10=2-00200
111-
12=1=12121==-=-=-
1==0-
2--2-0=0-=2=21
1==02-0=022-1=2-
1-112
1--01--2=2=
221=1=20-=0-==
1=2-0-21--
1=11
1120-=00-==2=
1-=1-02101-02
221-1=
1---=-=1211
22=
221-=21=2010
2-2102=
2--121=11-011
1-1-01-1=2=001
2-=-=22-=01--
1-0=20=22
2002122211=02
1-2-21-21211012=
2=0200201=
2=-102-
1==202=-2==1=
1=0=010120=
2==1100-01==-0
1220112102111=0
1=10=1-=-2=
1=-200020=-1001
11=11-=2
1==01=11=0=2-2==
2=0-0-1=11-222=
1221=0-1=
1-=1-022
10-1=22---021=1
1011-1-=22-12
1=0-122=-1==
2111-0=20=
1==01100-=
200111102
12=0-2=2112--121=1
2=01
1==221=2211--2011
"""
