import SwiftUI
import Combine

class CreateTripViewModel: ObservableObject {
    @Published var tripName: String = ""
    @Published var startDate: Date? = nil
    @Published var endDate: Date? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var createdTrip: Trip?
    
    private let tripService: TripServiceProtocol
    
    init(tripService: TripServiceProtocol = TripService()) {
        self.tripService = tripService
    }
    
    @MainActor
    func createTrip() async {
        guard !tripName.isEmpty else {
            errorMessage = String(localized: "validation.trip.name.empty")
            return
        }
        
        if let start = startDate, let end = endDate {
            guard end >= start else {
                errorMessage = String(localized: "validation.trip.dates.invalid")
                return
            }
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let trip = try await tripService.createTrip(name: tripName, startDate: startDate, endDate: endDate)
            createdTrip = trip
        } catch {
            errorMessage = String(localized: "error.generic.unknown")
        }
        
        isLoading = false
    }
}
