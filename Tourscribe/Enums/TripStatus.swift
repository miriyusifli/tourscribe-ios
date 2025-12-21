import SwiftUI

enum TripStatus: String {
    case current = "Current"
    case upcoming = "Upcoming"
    case past = "Past"
    
    var localizedName: String {
        switch self {
        case .current:
            return String(localized: "trip.status.current")
        case .upcoming:
            return String(localized: "trip.status.upcoming")
        case .past:
            return String(localized: "trip.status.past")
        }
    }
    
    var color: Color {
        switch self {
        case .current: return .green
        case .upcoming: return .primaryColor
        case .past: return .gray
        }
    }
}
