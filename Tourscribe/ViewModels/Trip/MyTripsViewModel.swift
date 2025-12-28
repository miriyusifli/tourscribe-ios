import SwiftUI
import Combine

@MainActor
class MyTripsViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var alert: AlertType? = nil
    @Published var selectedSegment: TripListSegment = .upcoming
    @Published var isShowingCreateTrip = false
    
    private let tripService: TripServiceProtocol
    private let tripStore: TripStore
    
    var trips: [Trip] { tripStore.trips }
    var hasMore: Bool { tripStore.hasMore }
    
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
            let page: TripPage
            if segment == .upcoming {
                page = try await tripService.fetchUpcomingTrips(cursor: nil, limit: AppConfig.tripsPageSize)
            } else {
                page = try await tripService.fetchPastTrips(cursor: nil, limit: AppConfig.tripsPageSize)
            }
            tripStore.set(page.trips, hasMore: page.hasMore)
        } catch {
            let nsError = error as NSError
            if nsError.code != NSURLErrorCancelled && !Task.isCancelled {
                alert = .error(String(localized: "error.generic.unknown"))
            }
        }
        
        isLoading = false
    }
    
    func loadMore() async {
        guard hasMore, !isLoadingMore, !isLoading else { return }
        
        isLoadingMore = true
        
        do {
            let page: TripPage
            if selectedSegment == .upcoming {
                page = try await tripService.fetchUpcomingTrips(cursor: tripStore.cursor, limit: AppConfig.tripsPageSize)
            } else {
                page = try await tripService.fetchPastTrips(cursor: tripStore.cursor, limit: AppConfig.tripsPageSize)
            }
            tripStore.append(page.trips, hasMore: page.hasMore)
        } catch {
            // Silent fail for load more
        }
        
        isLoadingMore = false
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
