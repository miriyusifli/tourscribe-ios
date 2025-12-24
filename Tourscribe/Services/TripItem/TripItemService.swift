import Foundation
import Supabase

class TripItemService: TripItemServiceProtocol {
    private let client = SupabaseClientManager.shared.client

    func fetchTripItems(for tripId: Int64) async throws -> [TripItem] {
        let response = try await client
            .from("trip_items")
            .select("id, trip_id, name, item_type, start_time, end_time, metadata, created_at, updated_at, trip_item_locations(*)")
            .eq("trip_id", value: String(tripId))
            .order("start_time", ascending: true, nullsFirst: false)
            .execute()
        
        return try JSONDecoders.iso8601.decode([TripItem].self, from: response.data)
    }

    func createTripItem(item: TripItemCreateRequest, locations: [Location]) async throws -> TripItem {
        let params = item.toRPCParams(locations: locations)
        let response = try await client.rpc("create_trip_item", params: params).execute()
        return try JSONDecoders.iso8601.decode(TripItem.self, from: response.data)
    }

    func updateTripItem(itemId: Int64, data: TripItemUpdateRequest, locations: [Location]?) async throws -> TripItem {
        //TODO implement me
        throw NSError(domain: "Not implemented", code: 0, userInfo: nil)
    }

    func deleteTripItem(itemId: Int64) async throws {
        //TODO implement me
        throw NSError(domain: "Not implemented", code: 0, userInfo: nil)
    }
}
