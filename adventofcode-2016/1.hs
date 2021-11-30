import Data.List.Split

data Direction = North | East | South | West deriving (Eq, Show, Enum)

rotate :: Direction -> Char -> Direction
rotate d c = toEnum $ case c of
    'R' -> (fromEnum d + 1) `mod` 4
    'L' -> (fromEnum d - 1) `mod` 4

data Location = Location {x::Int, y::Int} deriving Eq
instance Show Location where
    show (Location x y) = "(" ++ show x ++ ", " ++ show y ++ ")"

distance :: Location -> Int
distance loc = abs (x loc) + abs (y loc)

move :: Location -> Direction -> Int -> Location
move from dir noSteps = case dir of
    North -> from {y = y from + noSteps}
    South -> from {y = y from - noSteps}
    East -> from {x = x from + noSteps}
    West -> from {x = x from - noSteps}

data State = State {
    direction::Direction,
    location::Location
}

getLocations :: State -> [String] -> [Location]
getLocations state (t:l) = do 
    let components = getComponents t
    let newDirection = rotate (direction state) (turn components)
    let loc = location state
    let stepRange = [1..(steps components)]
    let newLocations = map (move loc newDirection) stepRange
    let newState = State newDirection $ last newLocations
    newLocations ++ getLocations newState l
getLocations _ [] = []

data Components = Components {
    turn::Char,
    steps::Int
}

getComponents :: String -> Components
getComponents (t:l) = Components t (read l :: Int)

getAllLocations :: String -> [Location]
getAllLocations input = do
    let initialState = State North $ Location 0 0
    getLocations initialState $ splitOn ", " input

solve1 :: [Location] -> String
solve1 locations = do
    let finalLocation = last locations
    show (distance finalLocation) ++ "\n"

firstDuplicate :: [Location] -> Location
firstDuplicate (x:xs) =
    if x `elem` xs
        then x
        else firstDuplicate xs

solve2 :: [Location] -> String
solve2 locations = show (distance $ firstDuplicate locations) ++ "\n"

solve :: String -> String
solve input = do
    let locations = getAllLocations input
    "First problem: " ++ solve1 locations ++ "Second problem: " ++ solve2 locations

main :: IO ()
main = interact solve
