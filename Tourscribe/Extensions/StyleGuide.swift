import SwiftUI
import Foundation
import CoreGraphics

enum StyleGuide {
    enum Spacing {
        static let none: CGFloat = 0
        static let xsmall: CGFloat = 2
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let standard: CGFloat = 12
        static let large: CGFloat = 16
        static let xlarge: CGFloat = 20
        static let xxlarge: CGFloat = 24
        static let routePath: CGFloat = 4
    }
    
    enum Padding {
        static let small: CGFloat = 8
        static let standard: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 20
        static let xlarge: CGFloat = 24
        static let xxlarge: CGFloat = 32
        static let huge: CGFloat = 60
    }
    
    enum CornerRadius {
        static let small: CGFloat = 8
        static let standard: CGFloat = 12
        static let large: CGFloat = 16
        static let xlarge: CGFloat = 20
        static let xxlarge: CGFloat = 24
    }

    enum IconSize {
        static let small: CGFloat = 16
        static let standard: CGFloat = 24
        static let medium: CGFloat = 32
        static let large: CGFloat = 48
        static let xlarge: CGFloat = 60
    }

    enum Typography {
        static let largeTitle: Font = .system(size: 34, weight: .bold, design: .rounded)
    }

    enum Dimensions {
        static let standardControlHeight: CGFloat = 42
        static let dividerHeight: CGFloat = 40
        static let dividerWidth: CGFloat = 1
        static let borderWidth: CGFloat = 1
        static let routeDotSize: CGFloat = 8
        static let routeLineHeight: CGFloat = 2
    }
}
