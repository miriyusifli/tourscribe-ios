import Foundation
import CoreGraphics

enum StyleGuide {
    enum Spacing {
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let standard: CGFloat = 12
        static let large: CGFloat = 16
        static let xlarge: CGFloat = 20
        static let xxlarge: CGFloat = 24
    }
    
    enum Padding {
        static let small: CGFloat = 8
        static let standard: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 20
        static let xlarge: CGFloat = 24
        static let xxlarge: CGFloat = 32
    }
    
    enum CornerRadius {
        static let small: CGFloat = 8
        static let standard: CGFloat = 12
        static let large: CGFloat = 16
        static let xlarge: CGFloat = 20
        static let xxlarge: CGFloat = 24
    }
}