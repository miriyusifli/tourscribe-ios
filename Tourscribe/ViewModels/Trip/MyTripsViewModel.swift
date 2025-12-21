import SwiftUI
import Combine

@MainActor
class MyTripsViewModel: ObservableObject {
    @Published var trips: [Trip] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let tripService: TripServiceProtocol
    
    init(tripService: TripServiceProtocol = TripService()) {
        self.tripService = tripService
    }
    
    func fetchTrips() async {
        isLoading = true
        errorMessage = nil
        
        do {
            trips = try await tripService.fetchTrips()
        } catch {
            errorMessage = String(localized: "error.generic.unknown")
        }
        
        isLoading = false
    }
}
