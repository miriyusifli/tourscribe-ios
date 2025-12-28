import SwiftUI
import Combine

class CreateTripViewModel: ObservableObject {
    @Published var tripName: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var createdTrip: Trip?
    
    private let tripService: TripServiceProtocol
    
    init(tripService: TripServiceProtocol = TripService()) {
        self.tripService = tripService
    }
    
    @MainActor
    func createTrip() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = try TripCreateRequest(name: tripName)
            let trip = try await tripService.createTrip(request: request)
            TripStore.shared.add(trip)
            createdTrip = trip
        } catch let error as TripValidationError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = String(localized: "error.generic.unknown")
        }
        
        isLoading = false
    }
}
