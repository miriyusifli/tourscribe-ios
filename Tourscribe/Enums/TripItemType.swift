import SwiftUI

enum TripItemType: String, Codable, CaseIterable, Hashable {
    case flight
    case accommodation
    case activity
    case restaurant

    var icon: String {
        switch self {
        case .flight: return "airplane"
        case .accommodation: return "bed.double.fill"
        case .activity: return "figure.walk"
        case .restaurant: return "fork.knife"
        }
    }
    
    var color: Color {
        switch self {
        case .flight: return .blue
        case .accommodation: return .purple
        case .activity: return .green
        case .restaurant: return .orange
        }
    }
    
    var description: String {
        switch self {
        case .flight:
            return "Book and track your flights."
        case .accommodation:
            return "Manage hotel and rental stays."
        case .activity:
            return "Plan tours, hikes, and visits."
        case .restaurant:
            return "Bookmark dining and reservations."
        }
    }
}
