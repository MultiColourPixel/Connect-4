//
//  Copyright © MultiColourPixel 2020
//

@testable import Connect_4

import XCTest

final class UIColorExtensionTests: XCTestCase {

    func testOctothorpDoesNotAffectColorCreation() {
        let red = UIColor(hexString: "#FF0000")
        XCTAssertEqual(red, .red)
    }

    func testColorCreationFromHex() {
        let blue = UIColor(hexString: "0000FF")
        XCTAssertEqual(blue, .blue)

        let white = UIColor(hexString: "FFFFFF")
        XCTAssertEqual(white, UIColor(red: 1, green: 1, blue: 1, alpha: 1))

        let black = UIColor(hexString: "000000")
        XCTAssertEqual(black, UIColor(red: 0, green: 0, blue: 0, alpha: 1))
    }

    func testEmptyHexCreatesWhiteColour() {
        let blank = UIColor(hexString: "")
        XCTAssertEqual(blank, UIColor(red: 1, green: 1, blue: 1, alpha: 1))
    }
}
