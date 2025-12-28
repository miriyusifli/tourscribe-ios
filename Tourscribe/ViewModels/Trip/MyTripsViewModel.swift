import SwiftUI
import Combine

@MainActor
class MyTripsViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var alert: AlertType? = nil
    @Published var selectedSegment: TripListSegment = .upcoming
    @Published var isShowingCreateTrip = false
    
    private let tripService: TripServiceProtocol
    private let tripStore: TripStore
    
    var trips: [Trip] { tripStore.trips }
    
    init(tripService: TripServiceProtocol = TripService(), tripStore: TripStore = .shared) {
        self.tripService = tripService
        self.tripStore = tripStore
    }
    
    func fetchTrips(for segment: TripListSegment) async {
        if tripStore.trips.isEmpty {
            isLoading = true
        }
        alert = nil
        
        do {
            let fetchedTrips: [Trip]
            if segment == .upcoming {
                fetchedTrips = try await tripService.fetchUpcomingTrips()
            } else {
                fetchedTrips = try await tripService.fetchPastTrips()
            }
            tripStore.set(fetchedTrips)
        } catch {
            let nsError = error as NSError
            if nsError.code != NSURLErrorCancelled && !Task.isCancelled {
                alert = .error(String(localized: "error.generic.unknown"))
            }
        }
        
        isLoading = false
    }
    
    func deleteTrip(tripId: Int64) async {
        do {
            try await tripService.deleteTrip(tripId: tripId)
            tripStore.remove(tripId)
        } catch {
            alert = .error(String(localized: "error.trip.delete_failed"))
        }
    }
}
