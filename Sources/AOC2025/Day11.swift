import Algorithms
import Shared

private func part1(input: String) -> Int {
    let devices = Dictionary(
        uniqueKeysWithValues: input.split(whereSeparator: \.isNewline).map { line in
            let splits = line.split(whereSeparator: \.isWhitespace).map(String.init)
            return (String(splits[0].dropLast()), Array(splits.dropFirst()))
        })
    return devices.paths(from: "you", to: "out").count
}

private func part2(input: String) -> Int {
    let devices = Dictionary(
        uniqueKeysWithValues: input.split(whereSeparator: \.isNewline).map { line in
            let splits = line.split(whereSeparator: \.isWhitespace).map(String.init)
            return (String(splits[0].dropLast()), Array(splits.dropFirst()))
        })
    // let graph = Graph(
    //     edges: devices.flatMap { node, outputs in
    //         outputs.map { Graph.Edge(from: node, to: $0, weight: 1) }
    //     })
    // print("start")
    // print(graph.edges.count)
    // print("paths", graph.paths(from: "svr", to: "fft"))
    // let toFFT = devices.paths(from: "svr", to: "fft")
    // print(toFFT)
    // let toDAC = devices.paths(from: "svr", to: "dac")
    // print(toDAC)
    // let fromFFT = devices.paths(from: "fft", to: "out")
    // print(fromFFT)
    // let fromDAC = devices.paths(from: "dac", to: "out")
    // print(fromDAC)
    return devices.paths(from: "svr", to: "out").filter { $0.contains("fft") && $0.contains("dac") }
        .count
}

extension Graph where T: Equatable {
    func paths(from start: T, to end: T) -> [[Edge]] {
        // var candidates = [edges.filter { $0.from == start }]
        // while !candidates.isEmpty {
        // }
        //
        // print("start", start, end)
        if start == end {
            return [[]]
        }
        let startCandidates = edges.filter { $0.from == start }
        let endCandidates = edges.filter { $0.to == end }
        let subGraph = Graph(
            edges: self.edges.filter {
                !startCandidates.contains($0) && !endCandidates.contains($0)
            })
        // print(subGraph.edges.count)
        // print("candidates", candidates)
        // print(startCandidates)
        // print(endCandidates)
        return startCandidates.flatMap { start in
            endCandidates.flatMap { end -> [[Edge]] in
                if start == end {
                    return [[start]]
                } else {
                    return subGraph.paths(from: start.to, to: end.from).map { [start] + $0 + [end] }
                }
            }
        }
        // return candidates.flatMap { next in
        //     return subGraph.paths(from: next.to, to: end).map { [next] + $0 }
        // }
    }
}

extension [String: [String]] {
    func paths(from start: String, to end: String) -> [[String]] {
        var paths = [[start]]
        while paths.contains(where: { $0.last != end }) {
            paths =
                paths.flatMap { path -> [[String]] in
                    if path.last == end {
                        return [path]
                    }
                    let candidates = self[path.last!]
                    guard let candidates else { return [] }
                    // print(path, candidates)
                    if candidates.contains(where: { path.contains($0) }) {
                        print("Loop", path, candidates)
                    }
                    return candidates.map { path + [$0] }
                }
        }
        return paths
    }
}

public let day11 = Solution(
    name: "day11",
    part1: part1,
    part2: part2
)
