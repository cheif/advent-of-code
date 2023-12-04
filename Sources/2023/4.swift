import Foundation
import Shared

public let day4 = Solution(
    part1: { input in
        let cards = input.split(whereSeparator: \.isNewline)
            .map { line in
                let splits = line.split(separator: ": ")[1].split(separator: " | ")
                    .map { sub in
                        sub.split(whereSeparator: \.isWhitespace).map { Int(String($0))! }
                    }
                return (splits[0], splits[1])
            }
        let points = cards.map { winners, has in
            let winning = has.filter(winners.contains(_:))
            let count = winning.count
            if count > 0 {
                return Int(truncating: pow(2, count - 1) as NSDecimalNumber)
            } else {
                return 0
            }
        }
        return points.sum
    },
    part2: { input in
        let cards = input.split(whereSeparator: \.isNewline)
            .map { line in
                let split = line.split(separator: ": ")
                let id = Int(split[0].split(whereSeparator: \.isWhitespace)[1])!
                let splits = split[1].split(separator: " | ")
                    .map { sub in
                        sub.split(whereSeparator: \.isWhitespace).map { Int(String($0))! }
                    }
                return (id, splits[0], splits[1])
            }
        let wins = cards.map { id, winners, has in
            let winning = has.filter(winners.contains(_:))
            let count = winning.count
            return count
        }
        var resultingCards = wins.map { (wins: $0, count: 1)}
        for i in resultingCards.indices {
            let card = resultingCards[i]
            for win in (0..<card.wins) {
//                print("Adding: \(card.count) at \(i + win + 1)")
                var new = resultingCards[i + win + 1]
                new.count += card.count
                resultingCards[i + win + 1] = new
            }
        }
//        print(resultingCards)
        return resultingCards.map(\.count).sum
    },
    testResult: (13, 30),
    testInput: """
Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
""",
    input: """
Card   1: 77 45  9 81 96  5 91  3 66 76 |  7 56 66 49 96 58 54 34 37  5 14 85 45 91  9 22 81 50 88 77 76  3 83 93 18
Card   2: 41 49 12 46 39  9 72 78 24 76 |  3 28 60 82  2 26 67 75 37 72 64 46 54 13 85 20 10  9 18 99 58  4 57 80 25
Card   3: 26 93 49 51 21 50 33 69 73 28 | 64 18 76 80 65 89 78 38 37 75 14 91 44 72 94 55 86 98  2  7 99 67 57 93 46
Card   4: 75 85 30 17 82 27 51 28 94 90 |  2  6  1 83 65 21 30 70 22 91 11 26 47 95 59 96 89 49  5 16 29 55 64 69 23
Card   5: 95 59 90 56 69 67 12 57  6 68 | 61 52 76 69 67 40 31 56 55 90 12 68 32 66  2 95 29  6 22 91 70 35 57 81 59
Card   6: 31 71 35 32 36 33 43 74 25 72 | 73 27 22 79 37 83 24 70  4 26 60 56 62 85  3 96 87 48 99 69 38 64 28 51 81
Card   7: 94 41 82 38 26 54 73 93 16 49 | 50 78  2 31 77 99 60 98 29 32 35 87  4 24 21 59 72 45 93 48 86  9 42 90 80
Card   8: 53 57 62 59 72 46 18 65 49 80 | 88  3 22 60 64 10 85 73 92 71 94 69 82 34 78 40 24  5 89 41 20 77 56 36 79
Card   9: 91 56 72 68  1 87 42 13 31 33 | 63 62 10 15 96 83 86 89 98 45 34 66 18 22 30  5 97 57 52 40 93 16 19 44 64
Card  10: 74 25 99 63 19 48 11 65 29 86 |  6 29 19  5 26 97 70 22 18 57  1 82 64 14 74 11 58 28 53 42 47 48 63 27 25
Card  11: 35 23  5 85 15 49 89 43 65 73 | 49 37 95 39  4 65 15 91 43 14 12 70 10 74 75 98 32 89 17 90 81 35 56 51  3
Card  12: 32 92  2 69 89 42 19 76 43 41 | 90 55 78 44 35 80 85 13 34 65 73 62 91 27 53 25 42  1 30 26  2 47 71 33 96
Card  13: 74 72 77 87 33 30 45 73  8 97 |  4 74 64  3 51 29 72 40 96 14 33 38 52  6 76 12 59 78 88 30 77 22 67  9 31
Card  14: 18 22 49 37  9  6 77 56 16 83 | 53 81 63 51 16 26 83 18 31 35 49  2 52 74 15 50 39 72 62 93  9 32 29 84 55
Card  15: 96 82 95 45 58 21  6 43 54 42 | 61 80 89 83 90 30  6 14 39  8  3 38 37 12 44 76 27 47 51 67 13 88 87 77 70
Card  16: 90 48 30 15 38 44 91  7 55 63 | 93 73 60 14 90 61 30 27 95 37 57 63  9 97 10 25 32 86 43 80  2 46 54 76 23
Card  17:  4  7 82 79 12 77  5 15 92 71 | 10 81 32 21 38 61 37 67 28 84 29 97 75 17 30 53 80 70  4 92 68 98 36 39  5
Card  18: 54 82 33  3 79 50 51 90 65 32 | 13 67 21 28 35 42 43 34 89 78 19 38 41 11 51 48 49  7 83 17 36 29 70 33 85
Card  19: 57 15 28 88 92 61 90  6  3 65 | 23 91 10 62 27 84 38 42 89 77 21 73 80 41 75 97 63 81  7 86 50 48 44  1 29
Card  20: 65 98 59 87 19 84  5 38  6 14 | 82 53 47  9 77 34 63 69 30 49 39 37  7 96 20 75 31 85 97 61 35 78 52 18 74
Card  21: 52 18 50 79 85 86 17 49 88 22 | 23 91 25 45 15 86 46 88 64 49 33 35 22 99 63 17 85 31 18 79 52 34 98 53 50
Card  22: 60  8 39 30 61 54 15 44 20 80 |  8 15 39  6 47 12 11 44 42 61 30 54 83 80 20 66  1 40 90 13 68 25 71 60 84
Card  23: 23 81  2 30 19 49  6 98 70 77 | 49  6  2 93 61 23 30 19 35 92  1 81 13 21 43  4 40 70 98 90 10 14 77 76 69
Card  24: 11 20 30 63 69 78 50  9 51 37 | 37 30 38 76 60 85 11 78 51 54 20 63 29 43 69 34  9 16 64 18 96 50 98 84 55
Card  25: 53 59 20 26 28 92 60 18 57 49 | 16 60 91 62 26 55 20  7 56 92 11  6 49 70  9 88 24 57 53 95 59 66 28 27 18
Card  26: 89 28 72 40 43 14 26 92 22 59 | 78 25 10 33 59 14 70 82 41 26 28 90 39 92 63 22 89 69  4 17 43  2 72 40 55
Card  27: 97 46 79 36 43 87 67 99 10 17 | 38  5 92 73 98 66 22 29  1 80 68 55  8 91 40 20 33 21 79  4 10 77  7 60 11
Card  28: 47 57 48 26 51  3 88 64 91 90 | 65 48 20 21 96 76 64 73 88 29 75  5 60  1 57 66 59 51 99 58  3  4 24 97 49
Card  29: 11 81 41 57 27  5 15 38 98 30 | 47 60 91 72 33  1 81 94 15 90 27 59 57 98  5 38 41 25 67 12 69 75 21 11 73
Card  30: 41 31 46 77 20 10 68 48 13 32 | 42  5 12 73 52 33 88  6 24 53 28 70 35 55 43 83 47 51 62 60 78 59 37 67 72
Card  31: 85 24 87 23 34 93 81 47 83  8 | 24 20 38 60 47 70 34  7 14  5  8  1 85 45 97 49 23 53 77 31 81 72 75 52 58
Card  32: 23 22 45 85 84 10 96 51 32 53 | 48 99 91  5 95 52 19 67  7 36 32 26 60 24 85 94 58 11 55 10 45 22 57 98 59
Card  33: 16 41 14  3 93 39 81 29 76 64 |  6 70 18 51 41 97 65  5 24 47 52 43 62  8 58 49 93 64 69 61 54 40 21 99 66
Card  34: 10 89 80 52 68 99 63 66 51 93 | 19 84 51 12 18 47 33 68 14 71 41 85 70 36 13 80  1 55 38  7 17 52 53  2 25
Card  35: 69 61 39 78  3 71 63 13 30 92 | 82 93  4 24  5 83 36 79  8 29 21 15 34 60 59 62 18 90 74 33 58 73 57 72 87
Card  36:  6 14 87 28 78 81 37 80 36 19 | 63 58 27 83  1 98 33  6 10 49 31 36 53 41 85  9 81 22 94 29 52 13 28 21 71
Card  37: 31 16 37 38 10 69 91 44 45 93 | 98 31 44 73 90 30 93 45 72 27 88 84 13 41 80 76 82 64  9 54 43 29 33  2 21
Card  38: 61 74 22 26 75 53 24 64 39 89 | 56 11 54 15 52 95 35 42 55 31 63 60 90 49 62  8 73 50  1 81 48 29 93 75 27
Card  39: 83 17 25 12 22 79 27 53  6 68 |  5 16 84 66 99  8 36 19 46 48 63 92  2 20 98 69 85 93 31 90  7 96 59 23 41
Card  40: 65 70 68 64 93 94 77 55 63 26 | 96 84  8 88 34 28 23 13 73 19  2 75 47 74  5 24 44 98 69 53 87 22 57 58 51
Card  41:  9 70 95 81 27 18 75 13 99 66 | 71 90 58 12 19 56 97  4 51 29 53 21 35 39 93 46  1 89 96 44 86 26  2 92 37
Card  42: 93  4 82 30 29 72 45 91 43 58 | 91 41 90 24 76 11 42  4 26 51 27 35 18 85  6 23 60  1 40 87 55 44 98  2 72
Card  43: 21 37 54 15 98 52 39 84 96 17 | 21  4 71 69 79 98 95 30 28 64 36 52 66 99  3 50 29 72 37 58 56 45 90 61 38
Card  44: 95 67 22 83  6 25 40  8 86 92 | 27 68 24 87 88 67 65 30 16 56 96 93 84 22 21 53 62 72 20 46 51 35 74 41 32
Card  45: 82 26 43 15 64 66 77 84 45 31 | 56 18 24 93  9 85 31 47 43 77 13 50 26 92 51 83 64 60 82 84 71 15 45  5 66
Card  46: 85 45 11 74  7 13 68 61 53 86 | 23 97 85 53 61 11 24 37 45 29 48 13 86 64 14 68 12 40 74 17 79 27  7 39 76
Card  47: 27 79 73 99 39 84 67 28 14 18 | 72 18 54 13 86 44 30 27 99 40 39 41 26  4 63 14 10  3 55 96 21 58 75 71 59
Card  48: 18 22 37 46 38 27 97 30 83 53 | 99 81 30 37 59 96 50 92 27 22  4 48 18 97 11 24 87 78 35 66 72 61 85  8 83
Card  49: 85 93 63 43 54 20 41 94 92 53 | 93 45 90 10 78  3 94 47 26 24 40 20 98 44 25 65 41 95 89 86 57 39 56 70 12
Card  50: 73 94 23  8 50 80 95 55 33 65 | 22 85  6 76 64  7 36  3 56 26 14 73 51 30 54  4 87 12 68 99 67 37 19 45 70
Card  51: 89 92 83 91  2 87 15 22 72 12 | 64 87 45 90 89  2 85 65 91 19 82 92 83 49 22 55 47 53 73 72 12 37 26 59 99
Card  52: 53  6  7 34 18 31 37 35 48 42 | 94 92 19 21  3 45 96 50 28 34 88 32 25 11 89 74 36 91 12 59 47  1 46 65 61
Card  53:  8 24  7 56 52 28 91 76 74 87 |  2 48 23 87 92 67 18 16 26 22 58 50 51 20 96 54 24 11 74  5  7 73 62 33 34
Card  54: 63 28 50 34 44 58 17 32 47 75 | 76  1 85 57 43 80 86 47  5 69 35 98 30 51 61 95 77 21 39 12 26 13 32 66 44
Card  55: 51 63 26 41 60 85 99  8 23 25 | 84 82 51 27 25  8 14 13 52 16 53 43 41 60 15 69 17 94 63 87 33  5 78 79 97
Card  56: 33 57 27  2 19 59 99 47 62 58 | 50 13 56  1 34 23  4 68 16 30 31 51  8 67 73 71 25 88 83 24 42 97 43 11 35
Card  57: 10 12 50 62 52  7 25  8  3 58 | 39 83 15 11 62 18  1 32 51 96 52 57 73  9 42 76 90  2 19 72 80  3 75 64 33
Card  58: 45  7 39  5 37 79 14 55  3 52 | 18 78 83 76 98 74  3 67 62 90  8 40 43 24  2  6 66 31 63 92 49 17 38 99 23
Card  59: 38 51 52  1 61 65 56 82 93 75 |  6 89 63 24 55 15 44 82  4 91 73 87 90 39 92 18 12 33 95 50 52 88 41 78 86
Card  60: 36 20 63 78 46  1 26 60 50  2 | 41 43  8 93  7 39 78  6 45 30 65 96 49 82 12 77 35 37 76 48 27 92 70 79 97
Card  61: 16 27 83 32 65 43 81 75 38 39 | 99 14 20  3 49 69 77 36  4 59 11 88  7 97 48  5 28 44 23 21 87 86  1 63 41
Card  62: 83 54  1 98 73 38 79 48 17 57 | 54 83 18 74 75 50 45 17 76 29 68 38 48 12 73  5  1 98 97 79 22 26 41 63 57
Card  63:  1 97  5 73 31 44  8 45 95 96 | 37 71 69 41 77 58 28 90 70 21 26  9 43 62 39 40 20 17 91 11  2 94 54 86 22
Card  64: 89 90 88 80 97 51 75 38 28 29 |  6  3 88 95 52 66  5  4 44 58 82 77 41 25 33 97 72 28 81 89 22 51 29 47 48
Card  65: 21 37 72 90 36 66 95 15 93 55 | 80 41 31 11 56 50 91 89 24 83  3 29 55 66 92 20 62 36 58 93 73 14 25  1 37
Card  66: 91 24 73 29 75 88 12 15 66 30 | 88 75 81 46 12 78 44 97 91 79 30 83 21 92 58 33 84 72 70 41  7 61  1 64 29
Card  67: 22 99 28 30 97 53  7 33 29 16 |  2 27 75  7 37 46 44 82 47 36 69 88 77 50 58 29 48 67 40 19 68 30 64 22 52
Card  68: 71 41 76 16 39 82  2 97 53 88 | 17 46 75 19 18 70 33 67 14 73 99 98  7  5 93 79 80 81 91 59 52 43 85 62 56
Card  69: 54 98 35 90  3 44  4 26 14 39 | 11 39 23 91 55 26  1 95 30 12 76 50 90 16 77  9 69 14 75 62 59  3 18  5 71
Card  70: 57 66 93 87 92 62 18  9 32 37 |  3 58 18 29 85 70 37 87 21 95 34 25 92  6 62 43 53  5 61 48 42 54 44 98 93
Card  71: 66 57 20 44 80 10 78 73 33 43 | 10 51 12 28 54 95 94 80 56 43  1 25 18 75 87 34 57  6 79  2 68 59 47  5 73
Card  72: 50 27 15 95  4 68 72 90  6 98 | 92 24 23 71 42 40 53 56 51 97 38 10 45 19  8 16 46 80 26 91 59 86  7 41 72
Card  73: 57 29 78 41 15 89 10 74 62 12 | 42 94 30  6 33 77 38 10 15 56 28 87  1 76 43 29 51 53  7 23 24 64  3  4 54
Card  74: 87 75 23 29 53 24 33 90  9 31 | 50 94 34  4 54  7 20 68 28 79 69 39 83 55 40 67 86 82 13 32 45 76 48 58 71
Card  75: 41 21 89 79 10 70 18 26 64 24 | 44 38 23 67 52 62 86 68 20 12 50 48 32 90 81 14 55 99 11 84 43 37 60 82  9
Card  76: 14 61 18 27 39 95 22 44 76 98 | 86 43  7 24 32 85 37  4 20 52 25 62 13 66  3 57 80 75 56 12 67 97 33 38 16
Card  77: 11 68 27 15 25 66 90 37 43 24 | 83 27 23 55 37 29 70 11 66 48 67 24 56 58 25 35 68 91 92 43 18  8 15 90 57
Card  78: 46 38 71 57 12 58  4 24 23 62 | 45  2 72 36 78 25 80 61 57 51 13 15  7  3 60 22  4 31 81 94 14 40 92 62 17
Card  79: 25 93 75  6  9  8 46 68 23 67 | 47 86 20 61 53 74 34 14  7 38 60 98 42 77 35  4 50  9 54 49 26 28 55 96 43
Card  80: 59 21 33 70 19  8 14 12 91 64 | 14 85 54 47 43 10  8 67 76 70 42 21 61 65 79 59 19 78  6 51 93  4 64 28 96
Card  81: 61 44 80 17 76 29 72 57 53 73 | 85 90 54 95 37 71 42 82  5 93 47 70  8 64 39 31 89 99 34 62 49 20 43 25 50
Card  82: 53 51 56  2 81 38 94 91  8 87 | 23 90 99 10 81 24 38 51 92 16 20 56 49  2  8 53 74 42 94 77 63 98 75 79 62
Card  83: 78 85  3 10 76 56  2 68 80 17 | 86 51 42 81  7 49 92 43 99 87 67 62  6 28 16 93 98 94  5 38 13 41  4 50 11
Card  84: 62 75 91  6  9 37 82 10 96 54 | 68 87 23 33 62 78 36 90 60 88 10 83 51  6 31 37 26 96 35  1 46 56  8 45 44
Card  85: 10 14  8 36 99 77 53 31 32 67 | 29 59 26  4 60 91 11 38 88 66 94 97 32 22 99 46 51 81 73 23  5 61 69 24 21
Card  86: 12 41 59 11 75 43 40 69  1 91 | 61 20 70 71 80 62  1 95 15 92 73 24 90 42  3 68 41 29 85 18 32 21 65 99 25
Card  87: 52 18  9 27 25 42 19 58 93 66 | 79 73 30 27 65 99 69 48 91 88 41  9 96 19 29 62  4 94 24 71 78 17 76 53  6
Card  88: 24 83 51 85 82  8 66 27 57 99 | 48 77 53 63 59 78 19 39 47 29 16 43 94 98  9 96 84  2 34 57 73 31 75 62 45
Card  89: 28 95  7 99 48 68 51 76 62 15 | 71 24 63 38 93  2 19 35 18 78 87 76 17 83 36 91 97 60 70 85 54 90 27 75 96
Card  90: 59 87 81 15 56 76 74 30 62 78 | 60  7 94 96 24 40 12 23 82 98 97 69  8 36 55 58 77 22 34 14 16 19 32 86 61
Card  91: 83 49 95 43 36 12 11 98 46 54 | 61 82 32 88 33 96 51 30 94 22 71 29 56 53 14 17 57 42 86 15 73 70 75 72 16
Card  92: 44 71 48 75 42 12 11 94 64 76 | 58 55 74 24 22 37 45 88 85 52 64 29 48 76 81 21 42 93 19 11 56  4  9 16 99
Card  93:  7 80 89 34  2 30 82 19 64 81 | 82 81 53 89  7 91 34 12  2 18 44 27 52 46 84 30 63 26 16 64 56 80 76 28 19
Card  94: 65 67 81 82  8 42 26  4 37 13 | 19 96  7 76 49 51 67 77 17 52 42 98 80 90 66 79 93 87 92 91 21 73  9 70 82
Card  95: 52 45 95 33 50 34 61  4 94  5 | 51 69  4 53 33 52 94 83 38  5 18 22  8 99 45 50 23 34 76 61 47 95 19 59 46
Card  96: 87 45 50 30 10 82  2 71 11 54 | 63 26 64 92  4 82 99 86 71 90 45 88 27 29 30 87 11 28  2 54 21 89 94 50 10
Card  97: 25 83 65 20 41 37 32 18 86 59 | 86 41  8 89 48 58 66 62 59 65 83 84 72 35 60 26 37 69 18 32  7 49 25 20 79
Card  98: 56 24 64 99 37 10 22 78 80  3 | 73 40 37 15 28 23  8 44 85 84 42 86 11 83 62 19 63 66 88 22 74 93 14 55 56
Card  99: 99 19 38 50  5 39 24 73 62 11 | 99 47 97 75  5 39 13 80  3  4 65  6 20 62 35 34 38 19 73 55 23 17 16 11 24
Card 100: 37 97 48 82 86 15 80 54 11 91 | 38 11 51 76 13 26  5 80 48 82 42 25 37 87 15 97 86 43 84 91 12 71 54 46 14
Card 101: 22 72 17 21 59 41 39 29  5 45 | 72 48  9 21 29 59 85 41 86 90 15 78 65 71 18 25 53 17 45  2 12 33  5 22 23
Card 102: 34 72 13 31 21 33 14 52 70  1 | 63 34 65 14  9 22 59 52 56 53 70 31 33 39  2 26 13  1 36 35 51 72 21 62 90
Card 103: 15 28 61 32 86 68 67  7 29 69 | 68 69 61 16 86 44  7  4 11 80 30 20 28 42 15 22 99 60 92  9  8 67 29 36 32
Card 104: 78 38 94 21 82 76 75 33 67 60 | 94 83 58 44 28 53 43 23 67 63 76 75 72 78  9 97  6 52 51 92 60 12 70 31 50
Card 105: 46 31 12 45 76 35 19 72 96 87 | 22 49 91 34 28 70 10 42 96 82 69 45 54 88 31 38 72 59 76 95 25 64 17 74 78
Card 106: 71 53 13 70 63 35 74 33 94 72 | 13 35 58 71 72 19 99 74 56 33 17 42 70 24 86 91 54 79 63  4 94  5  1 57  9
Card 107: 88 22 69 97 12 20 14 78 93 67 | 88 65  5  3 72 16 22 19 20 75 98 91 37 14 69 32 45 78 53 12 79 67 93  8  2
Card 108: 75 47  4 60 50 46 82 44 42 37 | 40 44 20 64 84 80 25 32 35 38 61 98 67 48 16 60 89 24 72 70 75 19 10 51 36
Card 109: 28 64 16 95 85 63 23 73 39 94 | 85 35 43 25 68  4 72 75 87 95 63 42 94 96 77  5 61  8 16 15 21 64 92 38 32
Card 110: 63 40 91 44 31 54 42 81 90 79 | 70 54 46 87 38 50 68 94  4 15 37 18 88 17 22 40 24 72 64 45 31 13 47 75 41
Card 111: 62 86 19 71 11 41 90 42 32 56 | 61 78 45 49 98 60 94 36 66 34 83 38 86 16 74  2 41 11 96 28 67  7 93 23 84
Card 112: 24 10 67  8 64 75 90 12 73 56 | 44 54 34  2 11 89 75  8 86 10 21 12 33  9 78 15 79 35 87 62 65 58 71  3 28
Card 113:  8 68 15 76 37 97 41 66 69 54 | 68 18 20 52 87 47 89 53  1 69 80 40 27 65 58 97  3 11 86 43 82  2  9 85 77
Card 114: 28 97 55 31 24 98 69 91 46 77 | 87 44 83 70 40 84  4 11 12 85 55 31 75 95 93 94 21 38 35 89 68 14 79 49 53
Card 115: 33 71 29 99 84 63 68 36 83 43 | 89 55 51 64 27 54 44 18 46  9 47 22 25 76 75 57 23 56  1 16 33 11 20  7 60
Card 116: 15  1  6 95 12 70 11 23 21 39 | 58 18 45 24 60 48 13 98 91 34 49 16 36 92 82 99 10 37  5 83 85 78 27 76 32
Card 117: 72 39 79 12 91  2  3 21 93 45 | 90 68 12 94 96 13 30 52 93 79 71 91 37 60 21 36 38 24  3 34 39 61 31 45  2
Card 118: 39 85 34 91 46  8 88 71 63 97 | 26 25 30 54 88 59 27 20 13 29 90 98 55 85 91 46 56 34 84 77 39 63 28 82  8
Card 119: 46 58 75 33 98 72 67 90 36  8 | 89 51  8 88 33 87 46 44 58 90  5 67 36  7 75  2 38 72 40 86 81 98 45 97 91
Card 120: 33 15 44 50 18 28 30 72 26 61 |  6 31 29 46 35 84 33 74 72 85 75 77 61 30 57 15 50 28  7 14 26 70 44 18 12
Card 121: 19 46 67 64 65 17 60 68 90 87 | 77 49 18 31  5 67 91 14 44 13 23 92 61 62 46 16 60  6 89 56 64  2 87 83 35
Card 122: 95 82 13 72 67 89 77 10 66 38 |  9 41 82 72 95 21  5 98 44 66 77 67 47 16  2 52 38 13 89 55 70 88 10  8 26
Card 123: 36 78 39 97 29 70 49 13 72 42 | 10 16 84 93 85 32 83 79  3 20 81 24 25 17  7 34 56 22  8 27 87 43 33 64 28
Card 124: 92  3 13 67 36 28 53 60 87 89 | 81  9 18 63 46 62 79 64 56 11 88 21 82 58 65 49 33 44 23 91 75 19 69 29 39
Card 125: 80 37 12 16 62 71 32 72 11 95 | 29 22 24 16 62  6 89 72 99 13 34 71 11 86  8 95 64 12 90 60 54 37 32 93 74
Card 126: 44 14 89 13 10 53 67 21  4 85 | 91 21 71 84 27 90 87 30  9 76 77 46 61 54 85 26 93 95 20 53 78 41 59 32 98
Card 127: 84 48 47 14 90 38 16  8 98 26 | 28 41 67 43 65  1 32 88 71 46 97 59 24 79 16 94 72 74 57 26 75 70  6 19 84
Card 128: 30 80 39 47 18  8 93 74 99 54 | 37  3 85 71 32 78 26 45 50 43 13 90 96 28 95 64  7 87 61 34 46 14 20 63 16
Card 129: 89  1 63 43 53 72  7 77 70 13 |  2 60  5 24 32 20 48 10 94 16 54 11 43 28 55 81 23 36  6 75 41 93 38 44 80
Card 130: 60 56 71 87 42  4  1 20 96 14 | 81 27 98 93 66 18 41 23 49 26 48  5 25 91 33 37 63 58 68 28 51  8 46 69 95
Card 131: 51  9 88 57 85 79 71  5 36 17 | 52 94 10 86 38 91  1 93 62  4 56 80 54 34 98 18  6 26 12 74 60 87 84 75 20
Card 132:  1 56 22 30 95 96 88 55 45 58 | 58 10 45 67 92 48 25 32 96  5 39 93 30 85 16 66 84 81 61 50 34  1 22 90 91
Card 133:  5 92 60 62 83 73 12 74 78 95 | 74 85 63 80 61 78 34 69 88 19 39 95 42 10 20 57 13 75 79 60 83 27 65 64 12
Card 134: 24 35 33 22 60 50  7 79 11 32 | 37 94 20 86 70 31 59  5 29 34 82 16 83 17 90 96 47 51 60 10 56 81  6 24 98
Card 135: 71 51 65 94 75 89 72 63 58 56 | 78 35 69 10 93 19 81 23 20 31 96 14 18  2 79 28 76 84 92 24 52 48 66 97 13
Card 136: 95  1 29 25 46 21 20 84  3 32 | 26 89 44 16  6 99 76 34 78 51 91 60 92 53 21 35 55 19 73 69  2  3 85  9 83
Card 137: 36 83 46 74 41 60 12 82 15 35 | 45 44 66 65 99 39 17 73 34 55 21 52 40 80 81 18 58 89 64 26 33 30 86 78 13
Card 138: 97  8 99 15 53 29 12 90 49 19 | 36 93 40 57 41 72 29 95 73 45 69 37 76  5  4 91  3  6 32 10 56 54 34 26 82
Card 139: 72 85  1 52 22 46 57 69 99 84 |  4 90 39 58 76 34 12 71 43  5 25  8 79 80 29 41 23 88 70 59 73 19 86 24 64
Card 140: 75 20 86 43 85 47 91 71 41 52 | 20 96 62 39 86 28 71 72 85 49  6 61 18 41 17  5 69  2 66 74 91 75 32 94 88
Card 141: 54 15 30 71 32 14 17 51 18 19 | 59 78 32 58 14 64 79 43 74 44 60 37 22 63 17 30 35 71 19 61 80 26 48 89 28
Card 142: 45 92 62 10 58 78  7 30 68 27 | 45 92 32 51 56 57 30 41 14 31 78 48  7 37 13 10 82 62 29 50 80 68 27  5 58
Card 143: 57 43  9 64 32 75 56 84 35 40 | 61 43 49 82 83 62 40 27 91 63 70 78 64  3  9 84 95 32 87 47 51 15 35 50 73
Card 144: 85 81 17 16 46 72 87 69 47  4 | 97 42 69 55 24 99 22  8 77  6 61  5  7 50  3 34 15 79 29 49 40 92 48 64 98
Card 145: 34 71 43 58 84 11 19 41  8 20 | 90 82 88 12 16 95 40 99 56 75 85 44  9 65 38 21 30 37 76 57 18 28 72 89 20
Card 146: 96 37 94 87 81 27 36 21 19 90 |  2  6 30 32 42 54 67 41 52 48 84 23 12 47 99 28 88 73 76 50  1 68 69 56 92
Card 147: 11 92 47  2 67 69 95 42 39 52 | 76  1 79 16  8 25 81 21 92 52 42  3 46 95 27 73 58 63 44 47 20 98 33 67 69
Card 148: 91 80 16 18 50 99 98 33 58 30 | 35 57 36 25 21 49 12 23 87 63 88 71 41 29 70 64 92 72 37 56 20 24 95 97 22
Card 149: 12 34 59 60 23 71 52 73 47 85 | 22 10 14 84  7 55 81 42 47 70 73 65 43 21 60 69 32 53 63 87 29 72 52 75 28
Card 150: 59 61 12 29 18 21 79 93 31  6 | 64 28 90 30 38 99 73 75 95 16 43 74 19 32 87 71 51 35 11 34 96 78  1 82  3
Card 151: 98 41 52 69 10  6 62 68 55 80 | 84  9 37 82 70  8 31 73 20 91 99 66 64 25  2  1 47 16  4 79 18 78 71 95 92
Card 152: 10 24 29 73  1 63 75 39 12 52 | 96 14 22 35 99 95 20 94 38 93 85 65  2 16 72 44 31  6 70 41 47 13 92 76 90
Card 153:  2 39 56 45 12 21 46 78  8 32 | 75 35 44 52 61 72 67 14 47  4 63 54 13 21 19 36 80 55 20 57 97 58 25 37 60
Card 154: 40 22 51 88 98  5 23 62  6 76 |  7 91  3 71 26 33 86 18 55 29 52 10 96 80 81 53 68 30 35 74 75 66 48 49 36
Card 155: 85 73 18  5 35 33 52 66 90 76 | 18 56 52 62  5 35 65 33 19 50  1 66  3  4 87 85 48 32 42 61 73 11 90 76 54
Card 156: 49 60 31 78 28 36 30 20 50 85 | 93  6 76  5  9  8 68 50 22 53 65  3 17  7 46 60  1 59 88 36 28 74 35 72 41
Card 157: 52 81 30 46 77 27 87 37 72  6 | 40 74 16 77 52 84 66 48 99 87 97 39 59 37 80  6 81 76 46 27 55 72 30 61  1
Card 158: 40 58 60 85  9 89 81 46 17 44 | 86 14 88 59 26 10 46 32 66 31 61 55 75 72  4 50 78 53 67 33 42 81 85 87  9
Card 159: 17 75 42 21 63 46 52 15 60 30 | 63 50 15 21 79 87 37 68 46 17 97 26 88 75 29 95 54 60 76 30 81 42 28 52 73
Card 160: 96 76 64 44 89 41 80 65 22 50 | 46  8 65 44 76 33 64  7 89 59 41 80 73 47 79 26 82 70 96 50 17 22 25 93  3
Card 161: 68 57 87  1  3 54 81 22 23 69 | 91 27 76 14 99 17 20 13 38 58 60 46 81 12 57 84 72 68 64 28 44 66  8 35 61
Card 162: 26 59 70 11 86 21 48  9  7  8 | 53 61 49 30 28 38 73 50 21 89  9 20  1 86 90 64 93 54 13 66  5 17 82 15 37
Card 163: 24 98 61 16 17 18 66 57 50 99 | 95 61 23 54 76 38 81 42 48 50 15 31 12 66 79 98 24 60 86 43 26 67 93 85 75
Card 164: 66 19 87 27 54 11 18 60 47 61 | 74 12 26 78 42  3 90 13  9 58 93 17 82 46 53 72 97 45 76 40 34 30 52 99 33
Card 165: 61 62 26 83 52 84 36  1  8 56 | 64 19 13 74 33 68 24 46 88 82 10 70 36 96 67 79  1 91 30 56 27  2 95  9 87
Card 166: 87 47 69 25 96 14 28 18 58 94 | 94  4 45 50 74 69 10 36 23 14 66 62 65 87 84 89 52 13 73 25 47 79 81 33 67
Card 167: 25 16 72 10 13 98 59 66  7 45 |  1 33 70  6 73 23 88 99 61 75 47 14 64 58 78 56 57 37 65 31 63 34 82 91 67
Card 168:  1 57 87 44 81 99 39 32 50 11 | 28 69 60 61 84 79 50  3 62 56 73 40 53 38 21 70  5 96 95 30  9 99  2 58 66
Card 169: 49 99 31  9 38  7 84 57 98 69 | 16  3 39 98 26  9 83 68  1 44 23 67 20 65 70 21 42 58 13 77 66 73 85 29 32
Card 170: 60 31 97 49 15 56 11 82  4 75 | 78 51  9 42 54 24 95 39 23 92 84 46 96 59 58 75 35  3 26 94 48 72 18 20 43
Card 171: 13 15 80 16 40 91 89 18 45 34 | 62 78 71 57 15 55 34 18 96 83 53  2 67 39 74  7 27 66 36 12 99 98  4 75 22
Card 172: 12 39 90 50 97 86 80 17 74 48 | 33 48 16 32 24 47 66 82 40 56 26 83  7 22 29 15 69 79 68 52 73 55 78 41 45
Card 173: 75 91 49 83 53 38 42 81 77 16 | 51 72 54 92 98 33 84 41  4 71 82 55 75 23 50  9 69  3 66 24 52 78 35 62 32
Card 174: 90 63 97 70 58 38 29  2  7 64 | 40 46 62 60 69 86 56 12 55 28 33 22 34 96 20 74 92 72 17 36 93 25 67 71 80
Card 175: 85 64 54 11 24 76 96 80  1 68 | 19 46 68 31 80 64 26 11 76 54 96 92 81  1 12 35 75 85 56 48 32 99 95 24 43
Card 176: 15 76 94 12 80 13 14 66 81 32 | 76 88 60 31 61 13 80 67 69 24 94 44 33  7 48 15 16 32 43 81 14 66 12 99 59
Card 177: 10  4 27 92 48 79 82 63 81  2 | 74 89 92  5 17 30 37 87 38 76 15 59  2 82 81 96 10 48 27 70  4 79 21 63 86
Card 178: 60 40 86 46 23 55  2 14 99 95 | 99 88 86 56 52 85 64 46 23 27 18 69 14 59 79 55 60 47 12 25 21  2 76 95 40
Card 179: 32 38 70 16 93 83  5 35 92 82 | 18 15 10 14 79 54 33 56 71 29 76 82 81  4 62 17 64 19 73 50 89 26 37 77 48
Card 180: 53 74 86 95 77 51 79 47 29 49 | 51 49 23 48 79 47 19 64 53 86 29 65 27  2 52 77 21 83 69 35 90 95 74 55 76
Card 181: 31 21 45 81 95  9 17 79 76 74 | 13  9 92 95 86 17 74  3 38  8 83 70 44 81 69 33 57 60 21 32 79 71 99 67 31
Card 182: 30 71 62 38 55 87 92 66 54 37 | 70 38 30 49 22 66 62  1 90  7 91 80  8 55 39  2 92 41 18 85 87 53 35 37 54
Card 183: 10 92  2 63 71 62 50 12 79 13 | 40 57 53 86 30 85 31 15 17 12 25 42 49 44 39 41 51 62 68 78 37  9 98  7 23
Card 184: 30  1 43 72 15 74 49 28 68  5 |  8  1 70 69 53 43 27 17 38 50 48 68 49 13 78 93 42 30 15 21 39 63 61 25 32
Card 185: 60 94 48 65  4 57 29 87 95 77 | 27 94 57 99 65 80 86  3 17 31 75 19 47 39 14 53 48 91 87 83  5 22 32 79  6
Card 186: 78 86 16 94 93 49 43 54 25 13 | 38 80  4 49 94 25  8 32 95 31 67 96 62 54 76 29 48 47 53 19 86 41 42 18 43
Card 187:  3 85 94 72 86  4 36 75 21 43 | 20 39 83 67 72 52 44 33  5 43 82 27 10 49 95 26 46 12 34 76 25 19 22  6 32
Card 188: 84 96 45 41 89  7  4 78 15 67 | 50 81 20 90 83 39 37 23 95 69 10 25 35 36 66 71 80 34 51  2 41 40 62 76 44
Card 189: 17 79 92  4 56 68  1 91 33 82 |  5 84 58 42 73  9 86 59 48 44 52 55 43 30 93 50 19 53 12 14 70 79 69 62 31
Card 190: 87 29 43 80 97 27 41 95 23 25 | 21 84 53 11 41 50 62 15 18 26 90 77 55 37 16 96  5 14 13  9 59  6 36 56 66
Card 191:  8 40 10 80 85 87 41 23 15 37 | 58 27 21 41 62  1 71 43 18 26 38  4  3  2 29 94 16 12 90 31 84 88 32 97 19
Card 192:  5 89 88 49 70 26 73  3 56 64 | 38 29 37 69 59 14 22 78 66  9 75 86 13 96 52 15 47 87 51 90 16  7 58 83 61
"""
)
