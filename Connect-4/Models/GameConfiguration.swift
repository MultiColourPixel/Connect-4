//
//  Copyright © MultiColourPixel 2020
//

import UIKit

struct GameConfiguration: Decodable {

    let id: Int
    let playerOneName: String
    let playerTwoName: String
    let playerOneColour: UIColor
    let playerTwoColour: UIColor

    private enum CodingKeys: String, CodingKey {
        case id
        case playerOneName = "name1"
        case playerTwoName = "name2"
        case playerOneColour = "color1"
        case playerTwoColour = "color2"
    }
}

extension GameConfiguration {

    init(from decoder: Decoder) throws {
        var rootArray = try decoder.unkeyedContainer()
        let container = try rootArray.nestedContainer(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        playerOneName = try container.decode(String.self, forKey: .playerOneName)
        playerTwoName = try container.decode(String.self, forKey: .playerTwoName)

        let playerOneHex = try container.decode(String.self, forKey: .playerOneColour)
        let playerTwoHex = try container.decode(String.self, forKey: .playerTwoColour)
        playerOneColour = UIColor(hexString: playerOneHex)
        playerTwoColour = UIColor(hexString: playerTwoHex)
    }
}
