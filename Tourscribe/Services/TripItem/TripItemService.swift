import Foundation
import Supabase

class TripItemService: TripItemServiceProtocol {
    private let client = SupabaseClientManager.shared.client

    func fetchTripItems(for tripId: Int64) async throws -> [TripItem] {
        let items: [TripItem] = try await client
            .from("trip_items")
            .select()
            .eq("trip_id", value: String(tripId))
            .order("start_time", ascending: true, nullsFirst: false)
            .execute()
            .value
        return items
    }

    func createTripItem(item: TripItemCreateRequest) async throws -> TripItem {
        let createdItem: TripItem = try await client
            .from("trip_items")
            .insert(item)
            .select()
            .single()
            .execute()
            .value
        return createdItem
    }

    func updateTripItem(itemId: Int64, data: TripItemUpdateRequest) async throws -> TripItem {
        let updatedItem: TripItem = try await client
            .from("trip_items")
            .update(data)
            .eq("id", value: String(itemId))
            .select()
            .single()
            .execute()
            .value
        return updatedItem
    }

    func deleteTripItem(itemId: Int64) async throws {
        try await client
            .from("trip_items")
            .delete()
            .eq("id", value: String(itemId))
            .execute()
    }
}
