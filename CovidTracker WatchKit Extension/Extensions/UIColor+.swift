//
//  UIColor+.swift
//  CovidTracker WatchKit Extension
//
//  Created by Bradley Bernard on 11/25/20.
//

import UIKit

extension UIColor {
    private struct ColorComponents {
        let red: CGFloat
        let green: CGFloat
        let blue: CGFloat
        let alpha: CGFloat
    }

    private func getComponents() -> ColorComponents {
        var red: CGFloat = 0
        var blue: CGFloat = 0
        var green: CGFloat = 0
        var alpha: CGFloat = 0

        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return ColorComponents(red: red, green: green, blue: blue, alpha: alpha)
    }

    var inverted: UIColor {
        let components = getComponents()

        // get the current values and make the difference from white:
        let compRed = 1.0 - components.red
        let compGreen = 1.0 - components.green
        let compBlue = 1.0 - components.blue

        return UIColor(red: compRed, green: compGreen, blue: compBlue, alpha: 1.0)
    }

    // perceptive luminance
    // https://stackoverflow.com/questions/1855884/determine-font-color-based-on-background-color
    var contrast: UIColor {
        let components = getComponents()

        let compRed = components.red * 0.299
        let compGreen = components.green * 0.587
        let compBlue = components.blue * 0.114

        let luminance = (compRed + compGreen + compBlue)

        let col: CGFloat = luminance < 0.55 ? 1 : 0

        return UIColor(red: col, green: col, blue: col, alpha: components.alpha)
    }

    func contrast(threshold: CGFloat = 0.65, bright: UIColor = .white, dark: UIColor = .black) -> UIColor {
        let components = getComponents()

        let compRed = 0.299 * components.red
        let compGreen = 0.587 * components.green
        let compBlue = 0.114 * components.blue

        let luminance = (compRed + compGreen + compBlue)
        return luminance < threshold ? dark : bright
    }
}
