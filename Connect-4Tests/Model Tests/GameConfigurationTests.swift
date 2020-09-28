//
//  Copyright © MultiColourPixel 2020
//

@testable import Connect_4

import XCTest

final class GameConfigurationTests: XCTestCase {

    let sampleResponse = Data("""
        [
            {
                "id":1234567890,
                "color1":"#FF0000",
                "color2":"#0000FF",
                "name1":"Sue",
                "name2":"Henry"
            }
        ]
        """.utf8)

    func testDecoding() throws {
        let decoder = JSONDecoder()
        
        let gameConfiguration = try decoder.decode(GameConfiguration.self, from: sampleResponse)

        XCTAssertEqual(gameConfiguration.id, 1234567890)
        XCTAssertEqual(gameConfiguration.playerOneName, "Sue")
        XCTAssertEqual(gameConfiguration.playerTwoName, "Henry")
        XCTAssertEqual(gameConfiguration.playerOneColour, .red)
        XCTAssertEqual(gameConfiguration.playerTwoColour, .blue)
    }
}
