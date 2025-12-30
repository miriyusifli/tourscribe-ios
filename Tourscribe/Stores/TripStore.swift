import SwiftUI

@Observable
@MainActor
class TripStore {
    static let shared = TripStore()
    
    private(set) var trips: [Trip] = []
    private(set) var hasMore: Bool = true
    
    private init() {}
    
    func set(_ trips: [Trip], hasMore: Bool) {
        self.trips = trips
        self.hasMore = hasMore
    }
    
    func append(_ trips: [Trip], hasMore: Bool) {
        self.trips.append(contentsOf: trips)
        self.hasMore = hasMore
    }
    
    func add(_ trip: Trip) {
        let tripDate = trip.startDate ?? .distantFuture
        var low = 0
        var high = trips.count
        while low < high {
            let mid = (low + high) / 2
            if (trips[mid].startDate ?? .distantFuture) < tripDate {
                low = mid + 1
            } else {
                high = mid
            }
        }
        trips.insert(trip, at: low)
    }
    
    func update(_ trip: Trip) {
        guard let index = trips.firstIndex(where: { $0.id == trip.id }) else { return }
        trips.remove(at: index)
        add(trip)
    }
    
    func remove(_ tripId: Int64) {
        trips.removeAll { $0.id == tripId }
    }
    
    func trip(for id: Int64) -> Trip? {
        trips.first { $0.id == id }
    }
    
    var cursor: TripCursor? {
        guard let last = trips.last else { return nil }
        return TripCursor(startDate: last.startDate, id: last.id)
    }
}
