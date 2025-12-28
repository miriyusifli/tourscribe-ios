import Foundation

@Observable
@MainActor
class CreateTripItemViewModel {
    private let tripId: Int64
    private let tripItemService: TripItemServiceProtocol
    private let tripService: TripServiceProtocol
    private let tripStore: TripStore
    
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
    var airline = ""
    var flightNumber = ""
    var carrier = ""
    var vehicleNumber = ""
    
    // UI State
    var isLoading = false
    var errorMessage: String?
    var createdItem: TripItem? = nil

    init(tripId: Int64, tripItemService: TripItemServiceProtocol = TripItemService(), tripService: TripServiceProtocol = TripService(), tripStore: TripStore = .shared) {
        self.tripId = tripId
        self.tripItemService = tripItemService
        self.tripService = tripService
        self.tripStore = tripStore
        self.endDateTime = Calendar.current.date(byAdding: .hour, value: 1, to: self.startDateTime) ?? self.startDateTime
    }
    
    func createTripItem() async {
        errorMessage = nil

        // Build locations array
        let locations: [Location]
        if selectedItemType.isMultiLocation {
            locations = [departureLocation, arrivalLocation]
                .compactMap { $0 }
                .enumerated()
                .map { $0.element.withSequence($0.offset) }
        } else {
            locations = [location].compactMap { $0?.withSequence(0) }
        }

        isLoading = true
        defer { isLoading = false }
        
        do {
            let request = try TripItemCreateRequest(
                tripId: tripId,
                name: name,
                itemType: selectedItemType,
                startDateTime: startDateTime,
                endDateTime: endDateTime,
                metadata: buildMetadata(),
                locations: locations
            )
            let newItem = try await tripItemService.createTripItem(request: request)
            await refreshTrip()
            self.createdItem = newItem
        } catch let error as TripItemValidationError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = String(localized: "error.generic.unknown")
        }
    }
    
    private func refreshTrip() async {
        guard let updatedTrip = try? await tripService.fetchTrip(tripId: tripId) else { return }
        tripStore.update(updatedTrip)
    }
    
    private func buildMetadata() -> TripItemMetadata {
        switch selectedItemType {
        case .flight:
            return .flight(FlightMetadata(airline: airline, flightNumber: flightNumber))
        case .accommodation:
            return .accommodation(AccommodationMetadata())
        case .activity:
            return .activity(ActivityMetadata())
        case .restaurant:
            return .restaurant(RestaurantMetadata())
        case .transport:
            return .transport(TransportMetadata(carrier: carrier, vehicleNumber: vehicleNumber))
        }
    }
}
