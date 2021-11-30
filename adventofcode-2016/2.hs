data State = One | Two | Three | Four | Five | Six | Seven | Eight | Nine deriving (Show, Enum)
move :: State -> Direction -> State
move state dir = do
    let n = fromEnum state
    let loc = toLoc state
    let newN = n + valueOf dir
    if newN >= 0 && newN < 9
        then do
        let newState = toEnum newN
        let newLoc = toLoc newState
        if x newLoc == x loc || y newLoc == y loc
            then newState
            else state
        else state

toLoc :: State -> Location
toLoc state = do
    let n = fromEnum state
    Location (n `mod` 3) (n `div` 3)

data Location = Location {
    x :: Int,
    y :: Int
}

data Direction = Up | Down | Left | Right
valueOf :: Direction -> Int
valueOf dir = case dir of
    Up -> -3
    Down -> 3
    Main.Left -> -1
    Main.Right -> 1

parse :: Char -> Direction
parse c = case c of
    'U' -> Up
    'D' -> Down
    'L' -> Main.Left
    'R' -> Main.Right

getNextNumber :: State -> String -> State
getNextNumber state input = do
    let directions = map parse input
    foldl move state directions

getNumbers :: State -> [String] -> [State]
getNumbers state (x:xs) = do 
    let nextState = getNextNumber state x
    nextState : getNumbers nextState xs
getNumbers _ [] = []

solve1 :: String -> String
solve1 input = do
    let l = lines input
    let states = getNumbers Five l
    show states

main :: IO ()
main = interact solve2

data State2 = State2 Int deriving Show
move2 :: State2 -> Direction -> State2
move2 state dir = do
    let x = state `mod` 5
    let canMoveUp = not $ elem state [State2 1, State2 2, State2 4, State2 5, State2 9]
    

solve2 :: String -> String
solve2 input = do
    let l = lines input
    let startState = State2 5 :: State2
    show startState
