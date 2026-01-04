import Foundation

protocol TripItemServiceProtocol {
    func fetchTripItems(for tripId: Int64, cursor: TripItemCursor?, limit: Int) async throws -> TripItemPage
    func fetchAllTripItems(for tripId: Int64) async throws -> [TripItem]
    func createTripItem(request: TripItemCreateRequest) async throws -> TripItem
    func updateTripItem(itemId: Int64, request: TripItemUpdateRequest) async throws -> TripItem
    func deleteTripItem(itemId: Int64) async throws
}
