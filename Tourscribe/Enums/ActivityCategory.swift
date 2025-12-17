import SwiftUI

enum ActivityCategory: String {
    case food = "Food"
    case museum = "Museum"
    case attraction = "Attraction"
    case transport = "Transport"
    case accommodation = "Accommodation"
    case shopping = "Shopping"
    case entertainment = "Entertainment"
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .museum: return "building.columns.fill"
        case .attraction: return "star.fill"
        case .transport: return "car.fill"
        case .accommodation: return "bed.double.fill"
        case .shopping: return "bag.fill"
        case .entertainment: return "theatermasks.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .food: return Color(red: 1.0, green: 0.6, blue: 0.2)
        case .museum: return Color(red: 0.6, green: 0.4, blue: 0.8)
        case .attraction: return Color(red: 1.0, green: 0.8, blue: 0.0)
        case .transport: return Color(red: 0.2, green: 0.7, blue: 0.9)
        case .accommodation: return Color(red: 0.3, green: 0.6, blue: 0.9)
        case .shopping: return Color(red: 0.9, green: 0.3, blue: 0.5)
        case .entertainment: return Color(red: 0.8, green: 0.2, blue: 0.6)
        }
    }
}
