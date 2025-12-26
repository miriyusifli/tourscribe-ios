import Foundation

@Observable
@MainActor
class UpdateTripViewModel {
    private let tripService: TripServiceProtocol
    private let originalTrip: Trip
    
    var name: String
    var startDate: Date?
    var endDate: Date?
    
    var isLoading = false
    var errorMessage: String?
    var updatedTrip: Trip?

    init(trip: Trip, tripService: TripServiceProtocol = TripService()) {
        self.originalTrip = trip
        self.tripService = tripService
        self.name = trip.name
        self.startDate = trip.startDate
        self.endDate = trip.endDate
    }
    
    func updateTrip() async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        
        do {
            let request = try TripUpdateRequest(
                name: name,
                startDate: startDate,
                endDate: endDate
            )
            updatedTrip = try await tripService.updateTrip(tripId: originalTrip.id, request: request)
        } catch let error as TripValidationError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = String(localized: "error.generic.unknown")
        }
    }
}
