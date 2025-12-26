import Foundation

enum TripValidationError: LocalizedError {
    case nameRequired
    case invalidNameFormat
    case invalidDateRange
    
    var errorDescription: String? {
        switch self {
        case .nameRequired:
            return String(localized: "error.trip.name_required")
        case .invalidNameFormat:
            return String(localized: "error.trip.invalid_name_format")
        case .invalidDateRange:
            return String(localized: "error.trip.invalid_date_range")
        }
    }
}
