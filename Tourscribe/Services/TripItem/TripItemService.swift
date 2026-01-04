import Foundation
import Supabase

class TripItemService: TripItemServiceProtocol {
    private let client = SupabaseClientManager.shared.client

    func fetchTripItems(for tripId: Int64, cursor: TripItemCursor?, limit: Int) async throws -> TripItemPage {
        
        var query = client
            .from("trip_items")
            .select("id, trip_id, name, item_type, start_datetime, end_datetime, metadata, version, created_at, updated_at, trip_item_locations(*)")
            .eq("trip_id", value: String(tripId))
        
        if let cursor = cursor {
            let cursorDateStr = DateFormatters.iso8601Date.string(from: cursor.startDateTime)
            query = query.gte("start_datetime", value: cursorDateStr)
            query = query.gt("id", value: String(cursor.id))
        }
        
        let response = try await query
            .order("start_datetime", ascending: true)
            .order("id", ascending: true)
            .limit(limit + 1)
            .execute()
        
        var items = try JSONDecoders.iso8601.decode([TripItem].self, from: response.data)
        let hasMore = items.count > limit
        if hasMore { items.removeLast() }
        
        return TripItemPage(items: items, hasMore: hasMore)
    }

    func fetchAllTripItems(for tripId: Int64) async throws -> [TripItem] {
        let response = try await client
            .from("trip_items")
            .select("id, trip_id, name, item_type, start_datetime, end_datetime, metadata, version, created_at, updated_at, trip_item_locations(*)")
            .eq("trip_id", value: String(tripId))
            .order("start_datetime", ascending: true)
            .order("id", ascending: true)
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
        do {
            let response = try await client.rpc("update_trip_item", params: params).execute()
            return try JSONDecoders.iso8601.decode(TripItem.self, from: response.data)
        } catch let error where error.localizedDescription.contains("VERSION_CONFLICT") {
            throw OptimisticLockError.versionConflict
        }
    }

    func deleteTripItem(itemId: Int64) async throws {
        try await client.rpc("delete_trip_item", params: ["p_item_id": itemId]).execute()
    }
}
