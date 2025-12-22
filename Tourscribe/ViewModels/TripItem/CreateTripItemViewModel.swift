import Foundation

@Observable
@MainActor
class CreateTripItemViewModel {
    private let tripId: Int64
    private let tripItemService: TripItemServiceProtocol
    
    // Form state
    var name = ""
    var selectedItemType: TripItemType = .activity
    var startTime = Date()
    var endTime: Date? = nil
    
    // Metadata properties
    var airline: String?
    var flightNumber: String?
    var address: String?
    var description: String?
    var cuisine: String?
    
    // UI State
    var isLoading = false
    var errorMessage: String? // Changed from 'alert'
    var createdItem: TripItem? = nil // Added for success signal

    init(tripId: Int64, tripItemService: TripItemServiceProtocol = TripItemService()) {
        self.tripId = tripId
        self.tripItemService = tripItemService
        self.endTime = Calendar.current.date(byAdding: .hour, value: 1, to: self.startTime)
    }
    
    func createTripItem() async { // No longer returns a value
        errorMessage = nil // Clear previous error
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please enter a name for the item." // TODO: Localize
            return
        }

        isLoading = true
        defer { isLoading = false }
        
        let metadata: TripItemMetadata?
        switch selectedItemType {
        case .flight:
            metadata = .flight(FlightMetadata(airline: airline, flightNumber: flightNumber))
        case .accommodation:
            metadata = .accommodation(AccommodationMetadata(address: address))
        case .activity:
            metadata = .activity(ActivityMetadata(description: description))
        case .restaurant:
            metadata = .restaurant(RestaurantMetadata(cuisine: cuisine))
        }
        
        let request = TripItemCreateRequest(
            tripId: tripId,
            name: name,
            itemType: selectedItemType,
            startTime: startTime,
            endTime: endTime,
            metadata: metadata
        )
        
        do {
            let newItem = try await tripItemService.createTripItem(item: request)
            self.createdItem = newItem // Set the published property on success
        } catch {
            self.errorMessage = String(localized: "error.generic.unknown") // Set error message
        }
    }
}
