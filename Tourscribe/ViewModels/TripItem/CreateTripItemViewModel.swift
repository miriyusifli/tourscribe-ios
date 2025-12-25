import Foundation

@Observable
@MainActor
class CreateTripItemViewModel {
    private let tripId: Int64
    private let tripItemService: TripItemServiceProtocol
    
    // Form state
    var name = ""
    var selectedItemType: TripItemType = .activity
    var startDateTime = Date()
    var endDateTime = Date()
    
    // Single location (for accommodation, restaurant, activity)
    var location: Location? = nil
    
    // Multi-location (for flight, transport)
    var departureLocation: Location? = nil
    var arrivalLocation: Location? = nil
    
    // Metadata properties
    var airline: String?
    var flightNumber: String?
    var checkIn: String?
    var checkOut: String?
    var carrier: String?
    var vehicleNumber: String?
    
    // UI State
    var isLoading = false
    var errorMessage: String?
    var createdItem: TripItem? = nil

    init(tripId: Int64, tripItemService: TripItemServiceProtocol = TripItemService()) {
        self.tripId = tripId
        self.tripItemService = tripItemService
        self.endDateTime = Calendar.current.date(byAdding: .hour, value: 1, to: self.startDateTime) ?? self.startDateTime
    }
    
    func createTripItem() async {
        errorMessage = nil
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = String(localized: "error.trip_item.name_required")
            return
        }

        // Validate locations based on type
        let locations: [Location]
        if selectedItemType.isMultiLocation {
            guard let departure = departureLocation, let arrival = arrivalLocation else {
                errorMessage = String(localized: "error.trip_item.locations_required")
                return
            }
            locations = [departure.withSequence(0), arrival.withSequence(1)]
        } else {
            guard let loc = location else {
                errorMessage = String(localized: "error.trip_item.location_required")
                return
            }
            locations = [loc.withSequence(0)]
        }

        isLoading = true
        defer { isLoading = false }
        
        let metadata = buildMetadata()
        
        let request = TripItemCreateRequest(
            tripId: tripId,
            name: name,
            itemType: selectedItemType,
            startDateTime: startDateTime,
            endDateTime: endDateTime,
            metadata: metadata
        )
        
        do {
            let newItem = try await tripItemService.createTripItem(item: request, locations: locations)
            self.createdItem = newItem
        } catch {
            self.errorMessage = String(localized: "error.generic.unknown")
        }
    }
    
    private func buildMetadata() -> TripItemMetadata {
        switch selectedItemType {
        case .flight:
            return .flight(FlightMetadata(airline: airline, flightNumber: flightNumber))
        case .accommodation:
            return .accommodation(AccommodationMetadata(checkIn: checkIn, checkOut: checkOut))
        case .activity:
            return .activity(ActivityMetadata())
        case .restaurant:
            return .restaurant(RestaurantMetadata())
        case .transport:
            return .transport(TransportMetadata(carrier: carrier, vehicleNumber: vehicleNumber))
        }
    }
}
