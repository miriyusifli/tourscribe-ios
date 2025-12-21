import SwiftUI
import Combine

@MainActor
class MyTripsViewModel: ObservableObject {
    @Published var trips: [Trip] = []
    @Published var isLoading: Bool = false
    @Published var alert: AlertType? = nil
    @Published var selectedSegment: TripListSegment = .upcoming
    @Published var isShowingCreateTrip = false
    
    private let tripService: TripServiceProtocol
    
    init(tripService: TripServiceProtocol = TripService()) {
        self.tripService = tripService
    }
    
    func fetchTrips(for segment: TripListSegment) async {
        if trips.isEmpty {
            isLoading = true
        }
        alert = nil
        
        do {
            if segment == .upcoming {
                trips = try await tripService.fetchUpcomingTrips()
            } else {
                trips = try await tripService.fetchPastTrips()
            }
        } catch {
            let nsError = error as NSError
            if nsError.code != NSURLErrorCancelled && !Task.isCancelled {
                alert = .error(String(localized: "error.generic.unknown"))
            }
        }
        
        isLoading = false
    }
    
    func deleteTrip(tripId: String) async {
        guard let id = Int64(tripId) else {
            print("Invalid tripId format: \(tripId)")
            return
        }

        do {
            try await tripService.deleteTrip(tripId: tripId)
        } catch {
            // If the delete fails, fetch the trips again to revert the UI change
            print("Error deleting trip: \(error.localizedDescription)")
            alert = .error(String(localized: "error.trip.delete_failed"))
            await fetchTrips(for: selectedSegment)
        }
        
        trips.removeAll { $0.id == id }
    }
}
