import Foundation
import Supabase

class TripService: TripServiceProtocol {
    private let client = SupabaseClientManager.shared.client
    
    func createTrip(request: TripCreateRequest) async throws -> Trip {
        let response = try await client.rpc("create_trip", params: request.toRPCParams()).execute()
        return try JSONDecoders.iso8601.decode(Trip.self, from: response.data)
    }
    
    func fetchUpcomingTrips() async throws -> [Trip] {
        let user = try await client.auth.session.user
        let nowStr = DateFormatters.iso8601Date.string(from: Date())
        
        let response = try await client
            .from("trips")
            .select()
            .eq("user_id", value: user.id)
            .or("end_date.gte.\(nowStr),end_date.is.null")
            .order("start_date", ascending: true)
            .execute()
            
        return try JSONDecoders.iso8601.decode([Trip].self, from: response.data)
    }
    
    func fetchPastTrips() async throws -> [Trip] {
        let user = try await client.auth.session.user
        let nowStr = DateFormatters.iso8601Date.string(from: Date())
        
        let response = try await client
            .from("trips")
            .select()
            .eq("user_id", value: user.id)
            .lt("end_date", value: nowStr)
            .order("start_date", ascending: false)
            .execute()
            
        return try JSONDecoders.iso8601.decode([Trip].self, from: response.data)
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
        let response = try await client.rpc("update_trip", params: request.toRPCParams(tripId: tripId)).execute()
        return try JSONDecoders.iso8601.decode(Trip.self, from: response.data)
    }
    
    func deleteTrip(tripId: Int64) async throws {
        try await client
            .from("trips")
            .delete()
            .eq("id", value: String(tripId))
            .execute()
    }
}
