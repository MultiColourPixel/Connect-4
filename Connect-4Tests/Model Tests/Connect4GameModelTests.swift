//
//  Copyright © MultiColourPixel 2020
//

@testable import Connect_4

import XCTest

final class Connect4GameModelTests: XCTestCase {

    private let gameModel = Connect4GameModel(winnerHandler: { _ in })

    // MARK: - Placement

    func testRecordPlacementAtColumnIndexOutsidePermittedRange_isNotAllowed() throws {
        XCTAssertFalse(gameModel.recordPlacement(atColumn: -1, player: .one))
        XCTAssertFalse(gameModel.recordPlacement(atColumn: 7, player: .one))
    }

    func testRecordPlacementAtColumnIndexInsidePermittedRange_isAllowed() throws {
        XCTAssertTrue(gameModel.recordPlacement(atColumn: 0, player: .one))
        XCTAssertTrue(gameModel.recordPlacement(atColumn: 6, player: .two))
    }

    func testRecordPlacementInColumnThatIsFull_isNotAllowed() throws {
        for _ in 0..<6 {
            gameModel.recordPlacement(atColumn: 0, player: .two)
        }

        XCTAssertFalse(gameModel.recordPlacement(atColumn: 0, player: .two))
    }

    // MARK: - Position checking

    func testSpacesLeftInColumnUpdatesAsPlacementsAreRecorded() {
        XCTAssertEqual(gameModel.spacesLeftInColumn(0), 6)

        gameModel.recordPlacement(atColumn: 0, player: .one)
        gameModel.recordPlacement(atColumn: 0, player: .one)
        XCTAssertEqual(gameModel.spacesLeftInColumn(0), 4)
    }

    // MARK: - Winning

    func testVerticalPlacementWin() throws {
        let winning = expectation(description: #function)
        let gameModel = Connect4GameModel(winnerHandler: { result in
            winning.fulfill()
            XCTAssertEqual(result, .success(.one))
        })

        gameModel.recordPlacement(atColumn: 0, player: .one)
        gameModel.recordPlacement(atColumn: 0, player: .one)
        gameModel.recordPlacement(atColumn: 0, player: .one)
        gameModel.recordPlacement(atColumn: 0, player: .one)

        waitForExpectations(timeout: 0)
    }

    func testHorizontalPlacementWin() throws {
        let winning = expectation(description: #function)
        let gameModel = Connect4GameModel(winnerHandler: { result in
            winning.fulfill()
            XCTAssertEqual(result, .success(.one))
        })

        gameModel.recordPlacement(atColumn: 0, player: .one)
        gameModel.recordPlacement(atColumn: 1, player: .one)
        gameModel.recordPlacement(atColumn: 2, player: .one)
        gameModel.recordPlacement(atColumn: 3, player: .one)

        waitForExpectations(timeout: 0)
    }

    func testDiagonalUpRightPlacementWin() throws {
        let winning = expectation(description: #function)
        let gameModel = Connect4GameModel(winnerHandler: { result in
            winning.fulfill()
            XCTAssertEqual(result, .success(.one))
        })

        /*
         The structure we're checking is:

                  ❌
               ❌ ⭕️
            ❌ ❌ ⭕️
         ❌ ⭕️ ⭕️ ⭕️ ❌

         */

        gameModel.recordPlacement(atColumn: 0, player: .one)
        gameModel.recordPlacement(atColumn: 1, player: .two)
        gameModel.recordPlacement(atColumn: 1, player: .one)
        gameModel.recordPlacement(atColumn: 2, player: .two)
        gameModel.recordPlacement(atColumn: 2, player: .one)
        gameModel.recordPlacement(atColumn: 3, player: .two)
        gameModel.recordPlacement(atColumn: 2, player: .one)
        gameModel.recordPlacement(atColumn: 3, player: .two)
        gameModel.recordPlacement(atColumn: 4, player: .one)
        gameModel.recordPlacement(atColumn: 3, player: .two)
        gameModel.recordPlacement(atColumn: 3, player: .one)

        waitForExpectations(timeout: 0)
    }

    func testDiagonalUpLeftPlacementWin() throws {
        let winning = expectation(description: #function)
        let gameModel = Connect4GameModel(winnerHandler: { result in
            winning.fulfill()
            XCTAssertEqual(result, .success(.one))
        })

        /*
         The structure we're checking is:

         ❌
         ⭕️ ❌ ⭕️
         ❌ ⭕️ ❌
         ❌ ⭕️ ⭕️ ❌

         */

        gameModel.recordPlacement(atColumn: 0, player: .one)
        gameModel.recordPlacement(atColumn: 1, player: .two)
        gameModel.recordPlacement(atColumn: 0, player: .one)
        gameModel.recordPlacement(atColumn: 0, player: .two)
        gameModel.recordPlacement(atColumn: 0, player: .one)
        gameModel.recordPlacement(atColumn: 1, player: .two)
        gameModel.recordPlacement(atColumn: 1, player: .one)
        gameModel.recordPlacement(atColumn: 2, player: .two)
        gameModel.recordPlacement(atColumn: 2, player: .one)
        gameModel.recordPlacement(atColumn: 2, player: .two)
        gameModel.recordPlacement(atColumn: 3, player: .one)

        waitForExpectations(timeout: 0)
    }

    // MARK: - Draw

    func testGameEndsWithDrawOnceAllTilesAreFilledWithNoOneWinning() throws {
        let draw = expectation(description: #function)
        let gameModel = Connect4GameModel(winnerHandler: { result in
            draw.fulfill()
            XCTAssertEqual(result, .failure(.draw))
        })

        // column 0
        gameModel.recordPlacement(atColumn: 0, player: .one)
        gameModel.recordPlacement(atColumn: 0, player: .two)
        gameModel.recordPlacement(atColumn: 0, player: .one)
        gameModel.recordPlacement(atColumn: 0, player: .one)
        gameModel.recordPlacement(atColumn: 0, player: .two)
        gameModel.recordPlacement(atColumn: 0, player: .two)

        // column 1
        gameModel.recordPlacement(atColumn: 1, player: .one)
        gameModel.recordPlacement(atColumn: 1, player: .one)
        gameModel.recordPlacement(atColumn: 1, player: .two)
        gameModel.recordPlacement(atColumn: 1, player: .two)
        gameModel.recordPlacement(atColumn: 1, player: .one)
        gameModel.recordPlacement(atColumn: 1, player: .one)

        // column 2
        gameModel.recordPlacement(atColumn: 2, player: .two)
        gameModel.recordPlacement(atColumn: 2, player: .two)
        gameModel.recordPlacement(atColumn: 2, player: .one)
        gameModel.recordPlacement(atColumn: 2, player: .one)
        gameModel.recordPlacement(atColumn: 2, player: .two)
        gameModel.recordPlacement(atColumn: 2, player: .two)

        // column 3
        gameModel.recordPlacement(atColumn: 3, player: .two)
        gameModel.recordPlacement(atColumn: 3, player: .one)
        gameModel.recordPlacement(atColumn: 3, player: .two)
        gameModel.recordPlacement(atColumn: 3, player: .two)
        gameModel.recordPlacement(atColumn: 3, player: .one)
        gameModel.recordPlacement(atColumn: 3, player: .two)

        // column 4
        gameModel.recordPlacement(atColumn: 4, player: .one)
        gameModel.recordPlacement(atColumn: 4, player: .two)
        gameModel.recordPlacement(atColumn: 4, player: .one)
        gameModel.recordPlacement(atColumn: 4, player: .one)
        gameModel.recordPlacement(atColumn: 4, player: .two)
        gameModel.recordPlacement(atColumn: 4, player: .one)

        // column 5
        gameModel.recordPlacement(atColumn: 5, player: .two)
        gameModel.recordPlacement(atColumn: 5, player: .one)
        gameModel.recordPlacement(atColumn: 5, player: .two)
        gameModel.recordPlacement(atColumn: 5, player: .two)
        gameModel.recordPlacement(atColumn: 5, player: .one)
        gameModel.recordPlacement(atColumn: 5, player: .two)

        // column 6
        gameModel.recordPlacement(atColumn: 6, player: .one)
        gameModel.recordPlacement(atColumn: 6, player: .two)
        gameModel.recordPlacement(atColumn: 6, player: .one)
        gameModel.recordPlacement(atColumn: 6, player: .one)
        gameModel.recordPlacement(atColumn: 6, player: .two)
        gameModel.recordPlacement(atColumn: 6, player: .one)

        waitForExpectations(timeout: 0)
    }
}
