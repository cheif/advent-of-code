import Foundation

public protocol SolutionProtocol {
    associatedtype Result: Equatable
    func part1(input: String) -> Result
    func part2(input: String) -> Result

    var testResult: (Result, Result) { get }
    var testInput: String { get }
    var part2TestInput: String? { get }
    var input: String { get }
}

public struct Solution<Result: Equatable> {
    public let part1: (String) -> Result
    public let part2: (String) -> Result

    public let testResult: (Result, Result)
    public let testInput: String
    public let part2TestInput: String?

    public let input: String

    public init(
        part1: @escaping (String) -> Result,
        part2: @escaping (String) -> Result,
        testResult: (Result, Result),
        testInput: String,
        part2TestInput: String? = nil,
        input: String
    ) {
        self.part1 = part1
        self.part2 = part2
        self.testResult = testResult
        self.testInput = testInput
        self.part2TestInput = part2TestInput
        self.input = input
    }
}

extension Solution: SolutionProtocol {
    public func part1(input: String) -> Result {
        part1(input)
    }
    
    public func part2(input: String) -> Result {
        part2(input)
    }
}

