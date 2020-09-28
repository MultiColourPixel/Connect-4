//
//  Copyright © MultiColourPixel 2020
//

@testable import Connect_4

import Combine
import XCTest

final class GameViewModelTests: XCTestCase {

    lazy var winningMoves = [0, 1, 0, 1, 0, 1, 0]
    lazy var drawMoves = [
        0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6,
        3, 3, 3, 0, 5, 4, 0, 6, 5, 4, 1, 2, 6, 1, 2, 2, 1, 6, 0, 5, 4,
    ]

    var subscriptions: Set<AnyCancellable> = []
    let viewModel = GameViewModel(gameService: MockGameService())

    func testPlayerDetailsUpdated_whenGameIsRestarted() {
        let gameService = MockGameService()
        let playerOneName = UUID().uuidString
        let playerTwoName = UUID().uuidString
        gameService.stubResult = .success(
            GameConfiguration(
                id: 1,
                playerOneName: playerOneName,
                playerTwoName: playerTwoName,
                playerOneColour: .yellow,
                playerTwoColour: .systemPink))

        let viewModel = GameViewModel(gameService: gameService)
        viewModel.restartGame()

        XCTAssertEqual(viewModel.playerOneName, playerOneName)
        XCTAssertEqual(viewModel.playerTwoName, playerTwoName)
        XCTAssertEqual(viewModel.playerOneColor, .yellow)
        XCTAssertEqual(viewModel.playerTwoColor, .systemPink)
    }

    func testIsLoadingIsTrue_whenGameIsBeingRestarted() {
        let loadingExpectation = expectation(description: #function)

        viewModel.$isLoading
            .sink { value in
                loadingExpectation.fulfill()

                XCTAssertTrue(value)
            }
            .store(in: &subscriptions)

        viewModel.restartGame()

        waitForExpectations(timeout: 0)
    }

    func testIsPlayableIsFalse_whenGameIsBeingRestarted() {
        let playableExpectation = expectation(description: #function)


        viewModel.$isPlayable
            .dropFirst()
            .sink { value in
                playableExpectation.fulfill()

                XCTAssertFalse(value)
            }
            .store(in: &subscriptions)

        viewModel.restartGame()

        waitForExpectations(timeout: 0)
    }

    func testIsPlayableIsTrue_afterGameIsRestarted() {
        let playableExpectation = expectation(description: #function)

        viewModel.$isPlayable
            .sink { value in
                playableExpectation.fulfill()

                XCTAssertTrue(value)
            }
            .store(in: &subscriptions)

        viewModel.restartGame()

        waitForExpectations(timeout: 0)
    }

    func testIsPlayableIsFalse_afterGameIsWon() {
        let playableExpectation = expectation(description: #function)

        viewModel.$isPlayable
            .dropFirst(2)
            .sink { value in
                playableExpectation.fulfill()

                XCTAssertTrue(value)
            }
            .store(in: &subscriptions)

        viewModel.restartGame()

        for move in winningMoves {
            viewModel.takeTurn(column:move)
        }

        waitForExpectations(timeout: 0)
    }

    func testCurrentPlayerNameIsUpdated_whenValidTurnIsTaken() {
        var currentStates: [String] = []

        viewModel.currentPlayStatePublisher
            .sink(receiveValue: { state in
                currentStates.append(state)
            })
            .store(in: &subscriptions)

        viewModel.restartGame()
        viewModel.takeTurn(column: 0)

        XCTAssertNotEqual(currentStates[0], currentStates[1])
    }

    func testCurrentPlayerNameDoesNotChange_whenInvalidTurnIsAttempted() {
        var currentStates: [String] = []

        viewModel.currentPlayStatePublisher
            .sink(receiveValue: { state in
                currentStates.append(state)
            })
            .store(in: &subscriptions)

        viewModel.restartGame()
        viewModel.takeTurn(column: -1)

        XCTAssertEqual(currentStates.count, 1)
    }

    func testCurrentPlayStatePublisherIndicatesWhoWon_whenGameIsWon() {
        let gameService = MockGameService()
        let playerOneName = "Bob"
        let playerTwoName = "Sue"
        gameService.stubResult = .success(
            GameConfiguration(
                id: 1,
                playerOneName: playerOneName,
                playerTwoName: playerTwoName,
                playerOneColour: .yellow,
                playerTwoColour: .systemPink))

        let viewModel = GameViewModel(gameService: gameService)
        var currentStates: [String] = []

        viewModel.currentPlayStatePublisher
            .sink { state in
                currentStates.append(state)
            }
            .store(in: &subscriptions)

        viewModel.restartGame()

        for move in winningMoves {
            viewModel.takeTurn(column:move)
        }

        XCTAssertEqual(currentStates.last, "Bob has won!")
    }

    func testCurrentPlayStatePublisherIndicatesGameIsDrawn_whenGameEndsInDraw() {
        let gameService = MockGameService()
        let playerOneName = "Bob"
        let playerTwoName = "Sue"
        gameService.stubResult = .success(
            GameConfiguration(
                id: 1,
                playerOneName: playerOneName,
                playerTwoName: playerTwoName,
                playerOneColour: .yellow,
                playerTwoColour: .systemPink))

        let viewModel = GameViewModel(gameService: gameService)
        var currentStates: [String] = []

        viewModel.currentPlayStatePublisher
            .sink { state in
                currentStates.append(state)
            }
            .store(in: &subscriptions)

        viewModel.restartGame()

        for move in drawMoves {
            viewModel.takeTurn(column:move)
        }

        XCTAssertEqual(currentStates.last, "This game has ended in a draw")
    }

    func testGameMovePublisherOutputs_whenValidMoveIsTaken() {
        let publisherExpectation = expectation(description: #function)

        viewModel.gameMovePublisher
            .sink(receiveValue: { _ in
                publisherExpectation.fulfill()
            })
            .store(in: &subscriptions)

        viewModel.restartGame()
        viewModel.takeTurn(column: 0)

        waitForExpectations(timeout: 0)
    }

    func testGameMovePublisherDoesNotOutput_whenInvalidMoveIsAttempted() {
        let publisherExpectation = expectation(description: #function)
        publisherExpectation.isInverted = true


        viewModel.gameMovePublisher
            .sink(receiveValue: { _ in
                publisherExpectation.fulfill()
            })
            .store(in: &subscriptions)

        viewModel.restartGame()
        viewModel.takeTurn(column: -1)

        waitForExpectations(timeout: 0)
    }

    func testRestartingGame_thenPreviouslyInvalidMoveBecomesValid() {
        let publisherExpectation = expectation(description: #function)
        publisherExpectation.expectedFulfillmentCount = 7

        viewModel.gameMovePublisher
            .sink(receiveValue: { _ in
                publisherExpectation.fulfill()
            })
            .store(in: &subscriptions)

        viewModel.restartGame()
        for _ in 0..<8 {
            viewModel.takeTurn(column: 0)
        }

        viewModel.restartGame()
        viewModel.takeTurn(column: 0)

        waitForExpectations(timeout: 0)
    }

    func testGameErrorPublisherOutputs_whenInvalidMoveIsAttempted() {
        let publisherExpectation = expectation(description: #function)

        viewModel.gameErrorPublisher
            .sink(receiveValue: { _ in
                publisherExpectation.fulfill()
            })
            .store(in: &subscriptions)


        viewModel.restartGame()
        viewModel.takeTurn(column: -1)

        waitForExpectations(timeout: 0)
    }

    func testGameErrorPublisherOutputs_whenRestartingGameFails() {
        let publisherExpectation = expectation(description: #function)

        let gameService = MockGameService()
        gameService.stubResult = .failure(.generalError)

        let viewModel = GameViewModel(gameService: gameService)

        viewModel.gameErrorPublisher
            .sink(receiveValue: { _ in
                publisherExpectation.fulfill()
            })
            .store(in: &subscriptions)

        viewModel.restartGame()

        waitForExpectations(timeout: 0)
    }

    func testGameOverPublisherOutputs_afterGameIsWon() {
        let gameOverExpectation = expectation(description: #function)
        let gameService = MockGameService()
        let playerOneName = UUID().uuidString
        let playerTwoName = UUID().uuidString
        gameService.stubResult = .success(
            GameConfiguration(
                id: 1,
                playerOneName: playerOneName,
                playerTwoName: playerTwoName,
                playerOneColour: .yellow,
                playerTwoColour: .systemPink))

        let viewModel = GameViewModel(gameService: gameService)

        viewModel.gameOverPublisher
            .sink { value in
                gameOverExpectation.fulfill()
                XCTAssertEqual(value, .win(playerOneName))
            }
            .store(in: &subscriptions)

        viewModel.restartGame()

        for move in winningMoves {
            viewModel.takeTurn(column:move)
        }

        waitForExpectations(timeout: 0)
    }

    func testGameOverPublisherOutputs_afterGameIsDrawn() {
        let gameOverExpectation = expectation(description: #function)

        viewModel.gameOverPublisher
            .sink { value in
                gameOverExpectation.fulfill()
                XCTAssertEqual(value, .draw)
            }
            .store(in: &subscriptions)

        viewModel.restartGame()

        for move in drawMoves {
            viewModel.takeTurn(column:move)
        }

        waitForExpectations(timeout: 0)
    }
}

private class MockGameService: GameConfigurationFetching {

    lazy var stubResult: Result<GameConfiguration, ServiceError> = .success(
        GameConfiguration(
            id: 1,
            playerOneName: UUID().uuidString,
            playerTwoName: UUID().uuidString,
            playerOneColour: .black,
            playerTwoColour: .blue))

    func fetchConfiguration(completionHandler: @escaping (Result<GameConfiguration, ServiceError>) -> Void) {
        completionHandler(stubResult)
    }
}
