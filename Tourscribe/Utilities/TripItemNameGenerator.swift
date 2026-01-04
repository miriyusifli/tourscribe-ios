import Foundation

struct TripItemNameGenerator {
    
    static func generateName(
        for itemType: TripItemType,
        location: Location? = nil,
        departureLocation: Location? = nil,
        arrivalLocation: Location? = nil
    ) -> String? {
        switch itemType {
        case .accommodation:
            guard let location else { return nil }
            return generateAccommodationName(location: location)
        case .restaurant:
            guard let location else { return nil }
            return generateRestaurantName(location: location)
        case .transport, .flight:
            guard let arrivalLocation else { return nil }
            return generateRouteName(itemType: itemType, arrival: arrivalLocation)
        case .activity:
            return nil
        }
    }
    
    private static func generateAccommodationName(location: Location) -> String {
        if !location.name.isEmpty {
            return location.name
        }
        if let locality = extractLocality(from: location) {
            return String(localized: "name_generator.accommodation_in \(locality)")
        }
        return String(localized: "name_generator.accommodation")
    }
    
    private static func generateRestaurantName(location: Location) -> String {
        if !location.name.isEmpty {
            return String(localized: "name_generator.meal_at \(location.name)")
        }
        if let locality = extractLocality(from: location) {
            return String(localized: "name_generator.meal_in \(locality)")
        }
        return String(localized: "name_generator.meal")
    }
    
    private static func generateRouteName(itemType: TripItemType, arrival: Location) -> String {
        let destination = arrival.city ?? arrival.country ?? arrival.name
        switch itemType {
        case .flight:
            return String(localized: "name_generator.flight_to \(destination)")
        case .transport:
            return String(localized: "name_generator.travel_to \(destination)")
        default:
            return destination
        }
    }
    
    private static func extractLocality(from location: Location) -> String? {
        location.city ?? location.country
    }
}
