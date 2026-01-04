import SwiftUI

enum TripListSegment: Int, CaseIterable, Identifiable {
    case upcoming = 0
    case past = 1
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .upcoming:
            return String(localized: "segment.trips", defaultValue: "Trips")
        case .past:
            return String(localized: "segment.past_trips", defaultValue: "Past Trips")
        }
    }
}
