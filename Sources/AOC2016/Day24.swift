import Algorithms
import Shared

private func part1(input: String) -> Int {
    let grid = Grid(string: input)
    let numbers = grid.data.filter { Int(String($0.val)) != nil }
    let start = numbers.first { $0.val == "0" }!

    let distances = distances(between: numbers, grid: grid)
    let shortest = aStar(start: State(visited: [start], totalCost: 0)) { state in
        state.visited.count == numbers.count
    } estimatedCostToFinish: { state in
            1_000
    } candidates: { state in
            let notVisited = numbers.filter { !state.visited.contains($0) }
            return notVisited.map { next in 
                let cost = distances
                    .first { points, _ in points.contains(state.visited.last!) && points.contains(next) }!
                    .distance
                return (
                    State(visited: state.visited + [next], totalCost: state.totalCost + cost), 
                    cost
                )
            }
    }
    return shortest?.last?.totalCost ?? 0
}

private func part2(input: String) -> Int {
    let grid = Grid(string: input)
    let numbers = grid.data.filter { Int(String($0.val)) != nil }
    let start = numbers.first { $0.val == "0" }!

    let distances = distances(between: numbers, grid: grid)
    let shortest = aStar(start: State(visited: [start], totalCost: 0)) { state in
        state.visited.count == numbers.count + 1
    } estimatedCostToFinish: { state in
            1_000
    } candidates: { state in
            var notVisited = numbers.filter { !state.visited.contains($0) }
            if notVisited.isEmpty && state.visited.last != start {
                notVisited.insert(start)
            }
            return notVisited.map { next in 
                let cost = distances
                    .first { points, _ in points.contains(state.visited.last!) && points.contains(next) }!
                    .distance
                return (
                    State(visited: state.visited + [next], totalCost: state.totalCost + cost), 
                    cost
                )
            }
    }
    return shortest?.last?.totalCost ?? 0
}

private struct State: Hashable {
    let visited: [Grid<Character>.Point]
    let totalCost: Int
}


private func distances(between numbers: Set<Grid<Character>.Point>, grid: Grid<Character>) -> [([Grid<Character>.Point], distance: Int)] {
    numbers.combinations(ofCount: 2).map { points in 
        let path = aStar(start: points[0]) { point in
            point == points[1]
        } estimatedCostToFinish: { point in
                point.distance(to: points[1])
            } candidates: { point in
                grid.neighbours(to: point)
                    .values
                    .filter { $0.val != "#" }
                    .map { ($0, cost: 1) }
            }
        return (points, distance: path!.dropLast().count)
    }
}

public let day24 = Solution(
    name: "day24",
    part1: part1,
    part2: part2
)
