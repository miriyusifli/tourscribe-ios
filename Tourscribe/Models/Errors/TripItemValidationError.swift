import Foundation

enum TripItemValidationError: LocalizedError {
    case nameRequired
    case invalidDateRange
    case locationRequired
    case flightLocationsRequired
    case flightMetadataRequired
    case transportMetadataRequired
    
    var errorDescription: String? {
        switch self {
        case .nameRequired:
            return String(localized: "error.trip_item.name_required")
        case .invalidDateRange:
            return String(localized: "error.trip_item.invalid_date_range")
        case .locationRequired:
            return String(localized: "error.trip_item.location_required")
        case .flightLocationsRequired:
            return String(localized: "error.trip_item.flight_locations_required")
        case .flightMetadataRequired:
            return String(localized: "error.trip_item.flight_metadata_required")
        case .transportMetadataRequired:
            return String(localized: "error.trip_item.transport_metadata_required")
        }
    }
}
