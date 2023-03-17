import Shared

public func day19() {
//    print(part1(input: test))
    print(part2(input: input))
}

private func part1(input: String) -> Int {
    let blueprints = input.split(whereSeparator: \.isNewline).map(Blueprint.init)
    return blueprints.map { blueprint in
        measure("calculateQualityLevel for blueprint \(blueprint.id)") {
            blueprint.calculateQualityLevel()
        }
    }.sum
}

private func part2(input: String) -> Int {
    let blueprints = input.split(whereSeparator: \.isNewline).map(Blueprint.init).prefix(3)
    return blueprints.map { blueprint in
        let cracked = measure("largestNumberOfGeodesCracked for blueprint \(blueprint.id)") {
            blueprint.largestNumberOfGeodesCracked(minutes: 32)
        }
        print("Cracked: \(cracked)")
        return cracked
    }.reduce(1, *)
}

private extension Blueprint {
    func calculateQualityLevel() -> Int {
        return id * largestNumberOfGeodesCracked(minutes: 24)
    }

    func largestNumberOfGeodesCracked(minutes: Int) -> Int {
        let state = State(
            minute: 0,
            materials: .zero,
            robots: Robots(ore: 1, clay: 0, obsidian: 0, geode: 0)
        )
        let maximized = maximizeIterative(
            state,
            finished: { $0.minute == minutes },
            score: \.materials.geode
            , maximumPotentialScore: { state in
                let timeToGo = minutes - state.minute
                let maximumAdditionalGeodeRobotsBuilt = (0..<timeToGo).sum
                return state.materials.geode + state.robots.geode * timeToGo + maximumAdditionalGeodeRobotsBuilt
            }
        ) { state in
            state.possibleStates(blueprint: self)
        }
        return maximized.last!.materials.geode
    }

    struct State: Hashable, CustomDebugStringConvertible {
        let minute: Int
        let materials: Materials
        let robots: Robots

        var debugDescription: String {
            return "== Minute \(minute) ==\n\(materials)\n\(robots)"
        }

        func possibleStates(blueprint: Blueprint) -> [Self] {
            blueprint.possibleBuilds(using: materials).map { candidate in
                State(
                    minute: minute + 1,
                    materials: candidate.materialsRemaining + self.robots.materialsHarvested(),
                    robots: robots + candidate.newRobots
                )
            }
        }
    }

    struct BuildCandidate: Hashable {
        let materialsRemaining: Materials
        let newRobots: Robots
    }

    private func possibleBuilds(using materials: Materials) -> [BuildCandidate] {
        var candidates: [BuildCandidate] = []

        if materials.canAfford(geodeRobotCost) {
            candidates.append(BuildCandidate(
                materialsRemaining: materials - geodeRobotCost,
                newRobots: Robots(ore: 0, clay: 0, obsidian: 0, geode: 1)
            ))
            // If we can build an geode robot, always do
            return candidates
        }
        // Add the no-op candidate
        candidates.append(BuildCandidate(materialsRemaining: materials, newRobots: Robots(ore: 0, clay: 0, obsidian: 0, geode: 0)))
        if materials.canAfford(obsidianRobotCost) {
            candidates.append(BuildCandidate(
                materialsRemaining: materials - obsidianRobotCost,
                newRobots: Robots(ore: 0, clay: 0, obsidian: 1, geode: 0)
            ))
        }
        if materials.canAfford(clayRobotCost) {
            candidates.append(BuildCandidate(
                materialsRemaining: materials - clayRobotCost,
                newRobots: Robots(ore: 0, clay: 1, obsidian: 0, geode: 0)
            ))
        }
        if materials.canAfford(oreRobotCost) {
            candidates.append(BuildCandidate(
                materialsRemaining: materials - oreRobotCost,
                newRobots: Robots(ore: 1, clay: 0, obsidian: 0, geode: 0)
            ))
        }
        return candidates
    }
}

private struct Robots: Hashable {
    let ore: Int
    let clay: Int
    let obsidian: Int
    let geode: Int

    func materialsHarvested() -> Materials {
        Materials(
            ore: self.ore,
            clay: self.clay,
            obsidian: self.obsidian,
            geode: self.geode
        )
    }

    static func + (lhs: Self, rhs: Self) -> Self {
        Self(ore: lhs.ore + rhs.ore, clay: lhs.clay + rhs.clay, obsidian: lhs.obsidian + rhs.obsidian, geode: lhs.geode + rhs.geode)
    }
}

private struct Materials: Hashable {
    let ore: Int
    let clay: Int
    let obsidian: Int
    let geode: Int

    static var zero: Materials { Materials(ore: 0, clay: 0, obsidian: 0, geode: 0) }

    static func + (lhs: Self, rhs: Self) -> Self {
        Self(ore: lhs.ore + rhs.ore, clay: lhs.clay + rhs.clay, obsidian: lhs.obsidian + rhs.obsidian, geode: lhs.geode + rhs.geode)
    }

    static func - (lhs: Self, rhs: Self) -> Self {
        Self(ore: lhs.ore - rhs.ore, clay: lhs.clay - rhs.clay, obsidian: lhs.obsidian - rhs.obsidian, geode: lhs.geode - rhs.geode)
    }

    func canAfford(_ other: Materials) -> Bool {
        return ore >= other.ore && clay >= other.clay && obsidian >= other.obsidian && geode >= other.geode
    }
}

private extension Materials {
    init(line: Substring) {
        // Drop prefix with robot name
        let line = line.dropFirst(20)
        self.ore = line.split(separator: " ore")[0].split(separator: " ").last.map { Int($0) ?? 0 } ?? 0
        self.clay = line.split(separator: " clay")[0].split(separator: " ").last.map { Int($0) ?? 0 } ?? 0
        self.obsidian = line.split(separator: " obsidian")[0].split(separator: " ").last.map { Int($0) ?? 0 } ?? 0
        self.geode = 0
    }
}

private struct Blueprint {
    let id: Int
    let oreRobotCost: Materials
    let clayRobotCost: Materials
    let obsidianRobotCost: Materials
    let geodeRobotCost: Materials

    init(line: Substring) {
        let splits = line.split(separator: ": ")
        id = Int(splits[0].split(separator: " ")[1])!
        let robotCosts = splits[1].split(separator: ". ")
        oreRobotCost = Materials(line: robotCosts[0])
        clayRobotCost = Materials(line: robotCosts[1])
        obsidianRobotCost = Materials(line: robotCosts[2])
        geodeRobotCost = Materials(line: robotCosts[3])
    }
}

private let test = """
Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.
Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.
"""

private let input = """
Blueprint 1: Each ore robot costs 2 ore. Each clay robot costs 4 ore. Each obsidian robot costs 3 ore and 20 clay. Each geode robot costs 2 ore and 17 obsidian.
Blueprint 2: Each ore robot costs 4 ore. Each clay robot costs 4 ore. Each obsidian robot costs 4 ore and 11 clay. Each geode robot costs 4 ore and 12 obsidian.
Blueprint 3: Each ore robot costs 4 ore. Each clay robot costs 4 ore. Each obsidian robot costs 3 ore and 19 clay. Each geode robot costs 4 ore and 15 obsidian.
Blueprint 4: Each ore robot costs 4 ore. Each clay robot costs 4 ore. Each obsidian robot costs 3 ore and 20 clay. Each geode robot costs 2 ore and 10 obsidian.
Blueprint 5: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 18 clay. Each geode robot costs 2 ore and 19 obsidian.
Blueprint 6: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 11 clay. Each geode robot costs 2 ore and 16 obsidian.
Blueprint 7: Each ore robot costs 4 ore. Each clay robot costs 3 ore. Each obsidian robot costs 4 ore and 8 clay. Each geode robot costs 3 ore and 7 obsidian.
Blueprint 8: Each ore robot costs 3 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 17 clay. Each geode robot costs 2 ore and 13 obsidian.
Blueprint 9: Each ore robot costs 3 ore. Each clay robot costs 4 ore. Each obsidian robot costs 3 ore and 12 clay. Each geode robot costs 3 ore and 17 obsidian.
Blueprint 10: Each ore robot costs 3 ore. Each clay robot costs 3 ore. Each obsidian robot costs 2 ore and 15 clay. Each geode robot costs 3 ore and 9 obsidian.
Blueprint 11: Each ore robot costs 3 ore. Each clay robot costs 3 ore. Each obsidian robot costs 2 ore and 16 clay. Each geode robot costs 2 ore and 18 obsidian.
Blueprint 12: Each ore robot costs 3 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 15 clay. Each geode robot costs 2 ore and 8 obsidian.
Blueprint 13: Each ore robot costs 4 ore. Each clay robot costs 3 ore. Each obsidian robot costs 4 ore and 11 clay. Each geode robot costs 3 ore and 15 obsidian.
Blueprint 14: Each ore robot costs 3 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 9 clay. Each geode robot costs 3 ore and 7 obsidian.
Blueprint 15: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 2 ore and 16 clay. Each geode robot costs 2 ore and 8 obsidian.
Blueprint 16: Each ore robot costs 3 ore. Each clay robot costs 4 ore. Each obsidian robot costs 4 ore and 16 clay. Each geode robot costs 3 ore and 15 obsidian.
Blueprint 17: Each ore robot costs 4 ore. Each clay robot costs 4 ore. Each obsidian robot costs 4 ore and 20 clay. Each geode robot costs 2 ore and 8 obsidian.
Blueprint 18: Each ore robot costs 2 ore. Each clay robot costs 4 ore. Each obsidian robot costs 4 ore and 13 clay. Each geode robot costs 3 ore and 11 obsidian.
Blueprint 19: Each ore robot costs 3 ore. Each clay robot costs 3 ore. Each obsidian robot costs 2 ore and 12 clay. Each geode robot costs 2 ore and 10 obsidian.
Blueprint 20: Each ore robot costs 3 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 19 clay. Each geode robot costs 3 ore and 19 obsidian.
Blueprint 21: Each ore robot costs 4 ore. Each clay robot costs 3 ore. Each obsidian robot costs 2 ore and 19 clay. Each geode robot costs 3 ore and 10 obsidian.
Blueprint 22: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 16 clay. Each geode robot costs 2 ore and 11 obsidian.
Blueprint 23: Each ore robot costs 4 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 10 clay. Each geode robot costs 3 ore and 10 obsidian.
Blueprint 24: Each ore robot costs 3 ore. Each clay robot costs 4 ore. Each obsidian robot costs 3 ore and 15 clay. Each geode robot costs 4 ore and 16 obsidian.
Blueprint 25: Each ore robot costs 4 ore. Each clay robot costs 3 ore. Each obsidian robot costs 2 ore and 5 clay. Each geode robot costs 2 ore and 10 obsidian.
Blueprint 26: Each ore robot costs 3 ore. Each clay robot costs 4 ore. Each obsidian robot costs 3 ore and 18 clay. Each geode robot costs 4 ore and 16 obsidian.
Blueprint 27: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 11 clay. Each geode robot costs 3 ore and 14 obsidian.
Blueprint 28: Each ore robot costs 4 ore. Each clay robot costs 4 ore. Each obsidian robot costs 2 ore and 7 clay. Each geode robot costs 4 ore and 13 obsidian.
Blueprint 29: Each ore robot costs 3 ore. Each clay robot costs 4 ore. Each obsidian robot costs 3 ore and 20 clay. Each geode robot costs 3 ore and 14 obsidian.
Blueprint 30: Each ore robot costs 4 ore. Each clay robot costs 3 ore. Each obsidian robot costs 4 ore and 8 clay. Each geode robot costs 2 ore and 8 obsidian.
"""
