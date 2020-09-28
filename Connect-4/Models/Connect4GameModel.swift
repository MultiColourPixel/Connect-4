//
//  Copyright © MultiColourPixel 2020
//

import Foundation

enum Player {
    case one
    case two

    fileprivate var bitboardIndex: Int {
        switch self {
        case .one: return 0
        case .two: return 1
        }
    }
}

struct GameConstants {
    static let columns = 7
    static let rows = 6
    static let maxMoves = 42
}

final class Connect4GameModel {

    private let winnerHandler: (Result<Player, WinError>) -> Void
    private let columnStartHeight = [0, 7, 14, 21, 28, 35, 42]
    private let invalidHeights = [6, 13, 20, 27, 34, 41, 48]

    private var moves: [Int] = []
    private var bitboards = [Bitboard(), Bitboard()]
    private lazy var columnBaseHeight = columnStartHeight

    init(winnerHandler: @escaping (Result<Player, WinError>) -> Void) {
        self.winnerHandler = winnerHandler
    }

    /// Check if the desired column has any spare rows into which a tile can be recorded into and if so, record the placement. If a user's move wins the game, the
    /// `winnerHandler`injected at initialisation will be called.
    /// - Parameters:
    ///   - atColumn: Zero based column index, with zero representing the left edge of the grid
    ///   - player: The player taking the turn
    /// - Returns: Returns `true` if placement is valid and was recorded, otherwise returns `false`
    @discardableResult
    func recordPlacement(atColumn column: Int, player: Player) -> Bool {
        guard
            0..<GameConstants.columns ~= column,
            isValidPlacement(column: column) else
        {
            return false
        }

        makeMove(atColumn: column, player: player)

        if checkIfWon(for: player) == true {
            winnerHandler(.success(player))
        } else if moves.count == GameConstants.maxMoves {
            winnerHandler(.failure(.draw))
        }

        return true
    }

    func spacesLeftInColumn(_ column: Int) -> Int {
        invalidHeights[column] - columnBaseHeight[column]
    }
}

private extension Connect4GameModel {

    func isValidPlacement(column: Int) -> Bool {
        columnBaseHeight[column] != invalidHeights[column]
    }

    func makeMove(atColumn column: Int, player: Player) {
        let move = Bitboard(rawValue: 1 << columnBaseHeight[column])

        bitboards[player.bitboardIndex] = bitboards[player.bitboardIndex].makeMove(move)

        moves.append(column)
        columnBaseHeight[column] += 1
    }

    func checkIfWon(for player: Player) -> Bool {
        let bitboard = bitboards[player.bitboardIndex]

        return bitboard.hasConnection(inDirections: Bitboard.Direction.allCases)
    }
}

extension Connect4GameModel {
    enum WinError: Error {
        case draw
    }
}
