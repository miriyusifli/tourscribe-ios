import SwiftUI

@Observable
@MainActor
class TripStore {
    static let shared = TripStore()
    
    private(set) var trips: [Trip] = []
    
    private init() {}
    
    func set(_ trips: [Trip]) {
        self.trips = trips
    }
    
    func add(_ trip: Trip) {
        trips.insert(trip, at: 0)
    }
    
    func update(_ trip: Trip) {
        if let index = trips.firstIndex(where: { $0.id == trip.id }) {
            trips[index] = trip
        }
    }
    
    func remove(_ tripId: Int64) {
        trips.removeAll { $0.id == tripId }
    }
    
    func trip(for id: Int64) -> Trip? {
        trips.first { $0.id == id }
    }
}
