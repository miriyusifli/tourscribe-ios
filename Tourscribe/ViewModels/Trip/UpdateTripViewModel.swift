import Foundation

@Observable
@MainActor
class UpdateTripViewModel {
    private let tripService: TripServiceProtocol
    private let tripStore: TripStore
    private let originalTrip: Trip
    
    var name: String
    
    var isLoading = false
    var errorMessage: String?
    var updatedTrip: Trip?

    init(trip: Trip, tripService: TripServiceProtocol = TripService(), tripStore: TripStore = .shared) {
        self.originalTrip = trip
        self.tripService = tripService
        self.tripStore = tripStore
        self.name = trip.name
    }
    
    func updateTrip() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        
        do {
            let request = try TripUpdateRequest(name: name)
            let trip = try await tripService.updateTrip(tripId: originalTrip.id, request: request)
            tripStore.update(trip)
            updatedTrip = trip
        } catch let error as TripValidationError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = String(localized: "error.generic.unknown")
        }
    }
}
