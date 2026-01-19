//
//  ProximaNova.swift
//  FlexJetting
//
//  Created by Jonathan on 1/19/26.
//

import Foundation
import SwiftUI

enum ProximaNova: String {
    case regular = "ProximaNova-Regular"
    case light = "ProximaNova-Light"
    case semiBold = "ProximaNova-Semibold"
    
    // Typo is in Font Assets
    case extraBold = "ProximaNova-Extrabld"
}

extension Font.TextStyle {
    var size: CGFloat {
        switch self {
            ///60
        case .largeTitle: return 60
        case .title: return 48
        case .title2: return 32
        case .title3: return 24
        case .headline, .body: return 18
        case .subheadline, .callout: return 15
        case .footnote: return 14
        case .caption, .caption2: return 12
        @unknown default:
            return 8
        }
    }
}

extension Font {
    static func custom(_ font: ProximaNova, relativeTo style: Font.TextStyle) -> Font {
            custom(font.rawValue, size: style.size, relativeTo: style)
        }
}
