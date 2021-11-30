import Foundation

var content = "R1, R1, R3, R1, R1, L2, R5, L2, R5, R1, R4, L2, R3, L3, R4, L5, R4, R4, R1, L5, L4, R5, R3, L1, R4, R3, L2, L1, R3, L4, R3, L2, R5, R190, R3, R5, L5, L1, R54, L3, L4, L1, R4, R1, R3, L1, L1, R2, L2, R2, R5, L3, R4, R76, L3, R4, R191, R5, R5, L5, L4, L5, L3, R1, R3, R2, L2, L2, L4, L5, L4, R5, R4, R4, R2, R3, R4, L3, L2, R5, R3, L2, L1, R2, L3, R2, L1, L1, R1, L3, R5, L5, L1, L2, R5, R3, L3, R3, R5, R2, R5, R5, L5, L5, R2, L3, L5, L2, L1, R2, R2, L2, R2, L3, L2, R3, L5, R4, L4, L5, R3, L4, R1, R3, R2, R4, L2, L3, R2, L5, R5, R4, L2, R4, L1, L3, L1, L3, R1, R2, R1, L5, R5, R3, L3, L3, L2, R4, R2, L5, L1, L1, L5, L4, L1, L1, R1"
//let input = ["R5", "L2", "L3"]
let input = content.components(separatedBy: ", ")
print(input)

var currentDirection = "N"
var x = 0
var y = 0

for instruction in input {
    let turn = instruction[instruction.index(instruction.startIndex, offsetBy: 0)]
    let steps = Int(instruction[instruction.index(instruction.startIndex, offsetBy: 1)..<instruction.endIndex])!
    if (currentDirection == "N") {
        if (turn == "R") {
            x += steps;
            currentDirection = "O"
        } else {
            x -= steps;
            currentDirection = "W"
        }
    } else if (currentDirection == "S") {
        if (turn == "L") {
            x += steps;
            currentDirection = "O"
        } else {
            x -= steps;
            currentDirection = "W"
        }
    } else if (currentDirection == "W") {
        if (turn == "R") {
            y += steps;
            currentDirection = "N"
        } else {
            y -= steps;
            currentDirection = "S"
        }
    } else {
        if (turn == "L") {
            y += steps;
            currentDirection = "N"
        } else {
            y -= steps;
            currentDirection = "S"
        }
    }
    print("Went \(steps) to \(currentDirection)")
}
print(abs(x) + abs(y))

x = 0
y = 0
currentDirection = "N"
var locationsVisited: [(Int, Int)] = []

outerLoop: for instruction in input {
    let turn = instruction[instruction.index(instruction.startIndex, offsetBy: 0)]
    let steps = Int(instruction[instruction.index(instruction.startIndex, offsetBy: 1)..<instruction.endIndex])!
    if ((currentDirection == "N" && turn == "R") || (currentDirection == "S" && turn == "L")) {
        currentDirection = "O"
    } else if ((currentDirection == "N" && turn == "L") || (currentDirection == "S" && turn == "R")) {
        currentDirection = "W"
    } else if ((currentDirection == "W" && turn == "R") || (currentDirection == "O" && turn == "L")) {
        currentDirection = "N"
    } else {
        currentDirection = "S"
    }
    for _ in 1...steps {
        let incr = 1
        if (currentDirection == "O") {
            x += incr
        } else if (currentDirection == "W") {
            x -= incr
        } else if (currentDirection == "N") {
            y += incr
        } else {
            y -= incr
        }
        let currentLocation = (x, y)
        if (locationsVisited.contains(where:{$0.0 == x && $0.1 == y})) {
            print("Found location \(currentLocation)")
            break outerLoop
        }

        locationsVisited += [currentLocation]
    }
    print("Went \(steps) to \(currentDirection)")
}
print(abs(x) + abs(y))
