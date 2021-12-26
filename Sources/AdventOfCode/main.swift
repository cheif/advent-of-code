import Foundation

let day = getToday()
let solution = getSolution(for: day)
print(solution(getInput(for: day)))

private func getSolution(for day: Int) -> (String) -> Any {
    switch day {
    case 1: return day1
    case 2: return day2
    case 3: return day3
    case 4: return day4
    case 5: return day5
    case 6: return day6
    case 7: return day7
    case 8: return day8
    case 9: return day9
    case 10: return day10
    case 11: return day11
    case 12: return day12
    case 13: return day13
    case 14: return day14
    case 15: return day15
    case 16: return day16
    case 17: return day17
    case 18: return day18
    case 19: return day19
    case 20: return day20
    case 21: return day21
    case 23: return day23
    case 24: return day24
    case 25: return day25
    default: fatalError("Not mapped yet")
    }
}

private func getInput(for day: Int) -> String {
    let url = Bundle.myModule.url(forResource: "inputs/\(day)", withExtension: nil)!
    return try! String(contentsOf: url)
}

private func getToday() -> Int {
    Calendar.current.component(.day, from: .init())
}

private final class BundleToken {}
private extension Bundle {
    // This doesn't seem to work with swift scripts, so we have to define our own :(
    static var myModule: Bundle {
        Bundle(path: "AdventOfCode_AdventOfCode.bundle")!
    }
}
