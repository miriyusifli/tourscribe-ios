import SwiftUI
import Combine

@MainActor
class MyTripsViewModel: ObservableObject {
    @Published var trips: [Trip] = []
    @Published var isLoading: Bool = false
    @Published var alert: AlertType?
    
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
}
