//
//  Copyright © MultiColourPixel 2020
//

import UIKit.UIColor

extension UIColor {

    convenience init(hexString: String) {
        guard !hexString.isEmpty else {
            self.init(red: 1, green: 1, blue: 1, alpha: 1)
            return
        }

        let trimmed = hexString.trimmingCharacters(in: ["#"])
        let scanner = Scanner(string: trimmed)

        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let red = (rgbValue & 0xff0000) >> 16
        let green = (rgbValue & 0xff00) >> 8
        let blue = (rgbValue & 0xff)
        let alpha = hexString.count == 8 ? rgbValue >> 24 : 255

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(alpha) / 255.0)
    }
}
