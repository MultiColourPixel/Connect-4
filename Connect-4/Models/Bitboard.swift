//
//  Copyright © MultiColourPixel 2020
//

struct Bitboard: RawRepresentable, Equatable {

    enum Direction: Int64, CaseIterable {
        case vertical = 1
        case horizontal = 7
        case diagonalNWSE = 6
        case diagonalSWNE = 8
    }

    // It would appear that John Tromp has one of the most well known solutions for a problem like this (http://tromp.github.io/c4/c4.html)

    /// Bit map representation of our board. To best understand the design of this data structure refer to
    /// https://github.com/denkspuren/BitboardC4/blob/master/BitboardDesign.md for a fairly straight forward explanation.
    ///
    ///  . .  .  .  .  .  .  TOP
    ///  5 12 19 26 33 40 47
    ///  4 11 18 25 32 39 46
    ///  3 10 17 24 31 38 45
    ///  2  9 16 23 30 37 44
    ///  1  8 15 22 29 36 43
    ///  0  7 14 21 28 35 42 BOTTOM
    let rawValue: Int64

    init(rawValue: Int64 = 0) {
        self.rawValue = rawValue
    }

    func makeMove(_ bitboard: Bitboard) -> Bitboard {
        self ^ bitboard
    }

    func hasConnection(inDirections directions: [Direction]) -> Bool {
        let rawDirections = directions.map { $0.rawValue }

        for direction in rawDirections {
            let singleShift = self >> Bitboard(rawValue: direction)
            let doubleShift = self >> Bitboard(rawValue: 2 * direction)
            let tripleShift = self >> Bitboard(rawValue: 3 * direction)

            if (self & singleShift & doubleShift & tripleShift != 0) {
                return true
            }
        }

        return false
    }
}

extension Bitboard {

    static func <<(lhs: Bitboard, rhs: Bitboard) -> Bitboard {
        Bitboard(rawValue: lhs.rawValue << rhs.rawValue)
    }

    static func >>(lhs: Bitboard, rhs: Bitboard) -> Bitboard {
        Bitboard(rawValue: lhs.rawValue >> rhs.rawValue)
    }

    static func |(lhs: Bitboard, rhs: Bitboard) -> Bitboard {
        Bitboard(rawValue: lhs.rawValue | rhs.rawValue)
    }

    static func ^(lhs: Bitboard, rhs: Bitboard) -> Bitboard {
        Bitboard(rawValue: lhs.rawValue ^ rhs.rawValue)
    }

    static func &(lhs: Bitboard, rhs: Bitboard) -> Bitboard {
        Bitboard(rawValue: lhs.rawValue & rhs.rawValue)
    }
}

extension Bitboard: ExpressibleByIntegerLiteral {

    init(integerLiteral value: Int64) {
        rawValue = value
    }
}
