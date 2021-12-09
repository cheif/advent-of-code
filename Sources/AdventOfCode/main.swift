import Foundation

let solution = getSolution(for: getToday())
print(solution(getInput(for: getToday())))

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
