import SwiftUI
import MapKit

enum TripItemType: String, Codable, CaseIterable, Hashable {
    case flight
    case accommodation
    case activity
    case restaurant
    case transport

    var icon: String {
        switch self {
        case .flight: return "airplane"
        case .accommodation: return "bed.double.fill"
        case .activity: return "figure.walk"
        case .restaurant: return "fork.knife"
        case .transport: return "bus.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .flight: return .blue
        case .accommodation: return .purple
        case .activity: return .green
        case .restaurant: return .orange
        case .transport: return .teal
        }
    }
    
    var lightColor: Color {
        color.opacity(0.1)
    }
    
    var lighterColor: Color {
        color.opacity(0.05)
    }
    
    var localizedName: String {
        switch self {
        case .flight: return String(localized: "trip_item.type.flight")
        case .accommodation: return String(localized: "trip_item.type.accommodation")
        case .activity: return String(localized: "trip_item.type.activity")
        case .restaurant: return String(localized: "trip_item.type.restaurant")
        case .transport: return String(localized: "trip_item.type.transport")
        }
    }
    
    var localizedDescription: String {
        switch self {
        case .flight: return String(localized: "trip_item.type.flight.description")
        case .accommodation: return String(localized: "trip_item.type.accommodation.description")
        case .activity: return String(localized: "trip_item.type.activity.description")
        case .restaurant: return String(localized: "trip_item.type.restaurant.description")
        case .transport: return String(localized: "trip_item.type.transport.description")
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
        case .transport:
            return "Track trains, buses, and transfers."
        }
    }
    
    var isMultiLocation: Bool {
        switch self {
        case .flight, .transport:
            return true
        case .accommodation, .activity, .restaurant:
            return false
        }
    }
    
    var pointOfInterestFilter: MKPointOfInterestFilter? {
        switch self {
        case .flight:
            return MKPointOfInterestFilter(including: [.airport])
        case .accommodation:
            return MKPointOfInterestFilter(including: [.hotel])
        case .restaurant:
            return MKPointOfInterestFilter(including: [.restaurant, .cafe, .bakery, .foodMarket])
        case .transport:
            return MKPointOfInterestFilter(including: [.publicTransport])
        case .activity:
            return nil // Show all for activities
        }
    }
}
