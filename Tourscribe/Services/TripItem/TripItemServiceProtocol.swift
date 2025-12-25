import Foundation

protocol TripItemServiceProtocol {
    func fetchTripItems(for tripId: Int64) async throws -> [TripItem]
    func createTripItem(request: TripItemCreateRequest) async throws -> TripItem
    func updateTripItem(itemId: Int64, data: TripItemUpdateRequest, locations: [Location]?) async throws -> TripItem
    func deleteTripItem(itemId: Int64) async throws
}
