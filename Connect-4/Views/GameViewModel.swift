//
//  Copyright © MultiColourPixel 2020
//

import Combine
import Foundation
import UIKit

struct GameMove {
    let indexPath: IndexPath
    let player: Player
}

final class GameViewModel {

    enum GameEndStatus: Equatable {
        case win(_ winner: String)
        case draw
    }

    private let gameService: GameConfigurationFetching

    @Published private(set) var playerOneName = ""
    @Published private(set) var playerTwoName = ""
    @Published private(set) var playerOneColor: UIColor = .clear
    @Published private(set) var playerTwoColor: UIColor = .clear
    @Published private(set) var isLoading = false
    @Published private(set) var isPlayable = false

    private lazy var gameLogic: Connect4GameModel = makeGameModel()
    private var currentPlayer: Player = .one {
        didSet {
            let name = currentPlayer == .one ? playerOneName : playerTwoName
            let possessive = "\(name)'s turn"
            currentPlayStatePublisher.send(possessive)
        }
    }

    let currentPlayStatePublisher = PassthroughSubject<String, Never>()
    let gameMovePublisher = PassthroughSubject<GameMove, Never>()
    let gameOverPublisher = PassthroughSubject<GameEndStatus, Never>()
    let gameErrorPublisher = PassthroughSubject<String, Never>()

    init(gameService: GameConfigurationFetching = GameConfigurationService()) {
        self.gameService = gameService
    }

    func restartGame() {
        fetchData()
        gameLogic = makeGameModel()
    }

    // If this were to be integrated with an online opponent, that sort of wiring would most likely go here.
    // The view model could communicate via a service just after a valid move is taken by the user.
    // It would also be trivial to make the game unplayable for the local user whilst we wait for a response from the cloud.
    // The service would also be injectable as to be able to test the VM a bit easier.

    func takeTurn(column: Int) {
        if gameLogic.recordPlacement(atColumn: column, player: currentPlayer) {
            let row = gameLogic.spacesLeftInColumn(column)
            let indexPath = IndexPath(row: row, section: column)
            gameMovePublisher.send(GameMove(indexPath: indexPath, player: currentPlayer))

            if isPlayable {
                currentPlayer = currentPlayer.nextPlayer()
            }
        } else {
            gameErrorPublisher.send("That move is invalid, please try again")
        }
    }
}

private extension GameViewModel {

    func fetchData() {
        isPlayable = false
        isLoading = true

        gameService.fetchConfiguration { [weak self] result in
            if let configuration = try? result.get() {
                self?.updateModel(configuration: configuration)
            } else {
                self?.gameErrorPublisher.send("There's been an error fetching game details")
            }
            self?.currentPlayer = .one
            self?.isPlayable = true
            self?.isLoading = false
        }
    }

    func updateModel(configuration: GameConfiguration) {
        playerOneName = configuration.playerOneName
        playerTwoName = configuration.playerTwoName
        playerOneColor = configuration.playerOneColour
        playerTwoColor = configuration.playerTwoColour
    }

    func markWinner(_ player: Player) {
        let winningPlayer = (player == .one) ? playerOneName : playerTwoName
        let descriptive = "\(winningPlayer) has won!"

        isPlayable = false
        currentPlayStatePublisher.send(descriptive)
        gameOverPublisher.send(.win(winningPlayer))
    }

    func markDraw() {
        isPlayable = false
        currentPlayStatePublisher.send("This game has ended in a draw")
        gameOverPublisher.send(.draw)
    }

    func makeGameModel() -> Connect4GameModel {
        return Connect4GameModel(winnerHandler: { [weak self] result in
            if let winner = try? result.get() {
                self?.markWinner(winner)
            } else {
                self?.markDraw()
            }
        })
    }
}

private extension Player {
    func nextPlayer() -> Player {
        (self == .one) ? .two : .one
    }
}
