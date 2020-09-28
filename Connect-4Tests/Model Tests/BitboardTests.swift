//
//  Copyright © MultiColourPixel 2020
//

@testable import Connect_4

import XCTest

final class BitboardTests: XCTestCase {

    // MARK: - Bit shifting

    func testBoardShiftLeftOperator() {
        let shifted = Bitboard(rawValue: 4) << 1
        XCTAssertEqual(shifted, 8)
    }

    func testBoardShiftRightOperator() {
        let shifted = Bitboard(rawValue: 4) >> 1
        XCTAssertEqual(shifted, 2)
    }

    func testBoardOROperator() {
        let or = Bitboard(rawValue: 0b101101) | Bitboard(rawValue: 0b100101)
        XCTAssertEqual(or, Bitboard(rawValue: 0b101101))
    }

    func testBoardXOROperator() {
        let xor = Bitboard(rawValue: 0b110011) ^ Bitboard(rawValue: 0b001111)
        XCTAssertEqual(xor, Bitboard(rawValue: 0b111100))
    }

    func testBoardAndOperator() {
        let and = Bitboard(rawValue: 0b110011) & Bitboard(rawValue: 0b001111)
        XCTAssertEqual(and, Bitboard(rawValue: 0b000011))
    }

    // MARK: - Making moves
    
    func testMakeMoveReturnsNewBitboard() {
        let board = Bitboard(rawValue: 0b110011)
        let move = Bitboard(rawValue: 0b001111)

        let updatedBoard = board.makeMove(move)

        XCTAssertEqual(updatedBoard, Bitboard(rawValue: 0b111100))
    }

    // MARK: - Winning

    func testHasConnectionVertically() {
        let board = Bitboard(rawValue: 0b001111)
        XCTAssertTrue(board.hasConnection(inDirections: [.vertical]))
    }

    func testHasConnectionHorizontally() {
        let board = Bitboard(rawValue: 0b1000000_1000000_1000000_1000000)
        XCTAssertTrue(board.hasConnection(inDirections: [.horizontal]))
    }

    func testHasConnectionDiagonallySouthWestToNorthEast() {
        let board = Bitboard(rawValue: 0b1000000_0100000_0010000_0001000)
        XCTAssertTrue(board.hasConnection(inDirections: [.diagonalSWNE]))
    }

    func testHasConnectionDiagonallyNorthWestToSouthEast() {
        let board = Bitboard(rawValue: 0b0001000_0010000_0100000_1000000)
        XCTAssertTrue(board.hasConnection(inDirections: [.diagonalNWSE]))
    }

    func testHasConnectionReturnsFalse_whenNoConnectionsExist() {
        let board = Bitboard(rawValue: 0b1110000_1110000_1110000_0000000)
        XCTAssertFalse(board.hasConnection(inDirections: Bitboard.Direction.allCases))
    }
}
