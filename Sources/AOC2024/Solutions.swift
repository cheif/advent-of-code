import Shared

public struct Solution<Result: Equatable>: SolutionProtocol {
    let part1: (String) -> Result
    let part2: (String) -> Result
    public let input: String

    public func part1(input: String) -> Result {
        part1(input)
    }

    public func part2(input: String) -> Result {
        part2(input)
    }
}
