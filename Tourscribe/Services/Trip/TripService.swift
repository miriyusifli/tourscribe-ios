import Foundation
import Supabase

class TripService: TripServiceProtocol {
    private let client = SupabaseClientManager.shared.client
    private let unsplashService: UnsplashServiceProtocol
    
    init(unsplashService: UnsplashServiceProtocol = UnsplashService()) {
        self.unsplashService = unsplashService
    }
    
    func createTrip(request: TripCreateRequest) async throws -> Trip {
        let imgUrl = try await unsplashService.fetchImageUrl(query: request.name)
        let response = try await client.rpc("create_trip", params: request.toRPCParams(imgUrl: imgUrl)).execute()
        return try JSONDecoders.iso8601.decode(Trip.self, from: response.data)
    }
    
    func fetchUpcomingTrips(cursor: TripCursor?, limit: Int) async throws -> TripPage {
        let userId = try await client.auth.session.user.id
        let nowStr = DateFormatters.iso8601Date.string(from: Date())
        
        var query = client
            .from("trips")
            .select()
            .eq("user_id", value: userId)
            .or("end_date.gte.\(nowStr),end_date.is.null")
        
        if let cursor = cursor {
            if let cursorDate = cursor.startDate {
                query = query.gte("start_date", value: DateFormatters.iso8601Date.string(from: cursorDate))
            }
            query = query.gt("id", value: String(cursor.id))
        }
        
        let response = try await query
            .order("start_date", ascending: true, nullsFirst: false)
            .order("id", ascending: true)
            .limit(limit + 1)
            .execute()
        
        return try decodePage(from: response.data, limit: limit)
    }
    
    func fetchPastTrips(cursor: TripCursor?, limit: Int) async throws -> TripPage {
        let userId = try await client.auth.session.user.id
        let nowStr = DateFormatters.iso8601Date.string(from: Date())
        
        var query = client
            .from("trips")
            .select()
            .eq("user_id", value: userId)
            .not("end_date", operator: .is, value: "null")
            .lt("end_date", value: nowStr)
        
        if let cursor = cursor {
            if let cursorDate = cursor.startDate {
                query = query.lte("start_date", value: DateFormatters.iso8601Date.string(from: cursorDate))
            }
            query = query.lt("id", value: String(cursor.id))
        }
        
        let response = try await query
            .order("start_date", ascending: false)
            .order("id", ascending: false)
            .limit(limit + 1)
            .execute()
        
        return try decodePage(from: response.data, limit: limit)
    }
    
    func fetchTrip(tripId: Int64) async throws -> Trip {
        let response = try await client
            .from("trips")
            .select()
            .eq("id", value: String(tripId))
            .single()
            .execute()
        
        return try JSONDecoders.iso8601.decode(Trip.self, from: response.data)
    }
    
    func updateTrip(tripId: Int64, request: TripUpdateRequest) async throws -> Trip {
        do {
            let response = try await client.rpc("update_trip", params: request.toRPCParams(tripId: tripId)).execute()
            return try JSONDecoders.iso8601.decode(Trip.self, from: response.data)
        } catch let error where error.localizedDescription.contains("VERSION_CONFLICT") {
            throw OptimisticLockError.versionConflict
        }
    }
    
    func deleteTrip(tripId: Int64) async throws {
        try await client
            .from("trips")
            .delete()
            .eq("id", value: String(tripId))
            .execute()
    }
    
    private func decodePage(from data: Data, limit: Int) throws -> TripPage {
        var trips = try JSONDecoders.iso8601.decode([Trip].self, from: data)
        let hasMore = trips.count > limit
        if hasMore { trips.removeLast() }
        return TripPage(trips: trips, hasMore: hasMore)
    }
}
