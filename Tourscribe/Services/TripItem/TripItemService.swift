import Foundation
import Supabase

class TripItemService: TripItemServiceProtocol {
    private let client = SupabaseClientManager.shared.client

    func fetchTripItems(for tripId: Int64) async throws -> [TripItem] {
        let response = try await client
            .from("trip_items")
            .select("id, trip_id, name, item_type, start_datetime, end_datetime, metadata, created_at, updated_at, trip_item_locations(*)")
            .eq("trip_id", value: String(tripId))
            .order("start_datetime", ascending: true)
            .execute()
        
        return try JSONDecoders.iso8601.decode([TripItem].self, from: response.data)
    }

    func createTripItem(request: TripItemCreateRequest) async throws -> TripItem {
        let params = request.toRPCParams()
        let response = try await client.rpc("create_trip_item", params: params).execute()
        return try JSONDecoders.iso8601.decode(TripItem.self, from: response.data)
    }

    func updateTripItem(itemId: Int64, request: TripItemUpdateRequest) async throws -> TripItem {
        let params = request.toRPCParams(itemId: itemId)
        let response = try await client.rpc("update_trip_item", params: params).execute()
        return try JSONDecoders.iso8601.decode(TripItem.self, from: response.data)
    }

    func deleteTripItem(itemId: Int64) async throws {
        try await client
            .from("trip_items")
            .delete()
            .eq("id", value: String(itemId))
            .execute()
    }
}
