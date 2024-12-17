import Foundation
import Shared

public struct Solution<Result: Equatable>: SolutionProtocol, @unchecked Sendable {
    let name: String
    let part1: (String) -> Result
    let part2: (String) -> Result

    public func part1(input: String) -> Result {
        part1(input)
    }

    public func part2(input: String) -> Result {
        part2(input)
    }

    public var input: String {
        guard let url = Bundle.module.url(forResource: name, withExtension: nil),
              let input = try? String(contentsOf: url, encoding: .utf8) else {
            fatalError("Input not found")
        }
        return input
    }
}
