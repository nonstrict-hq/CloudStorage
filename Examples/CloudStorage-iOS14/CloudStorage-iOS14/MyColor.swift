//
//  MyColor.swift
//  CloudStorage-iOS14
//
//  Created by Tom Lokhorst on 2020-07-18.
//

import SwiftUI

// Note: This example is not for production use.
// This ignores color space, forces 8-bit sRGB
struct MyColor: RawRepresentable {
    var rawValue: Int

    init(_ uiColor: UIColor) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)
        let a = Int(alpha * 255)

        rawValue = (r << 24) | (g << 16) | (b << 8) | a
    }

    init?(rawValue: Int) {
        self.rawValue = rawValue
    }

    var uiColor: UIColor {
        let r = (rawValue >> 24) & 0xff
        let g = (rawValue >> 16) & 0xff
        let b = (rawValue >> 8) & 0xff
        let a = rawValue & 0xff

        return UIColor(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255)
    }
}

extension Color {
    init(_ myColor: MyColor) {
        self.init(myColor.uiColor)
    }
}
