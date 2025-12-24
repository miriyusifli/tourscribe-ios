import Foundation
import Supabase

class TripService: TripServiceProtocol {
    private let client = SupabaseClientManager.shared.client
    
    func createTrip(name: String, startDate: Date?, endDate: Date?) async throws -> Trip {
        let request = TripCreateRequest(name: name, startDate: startDate, endDate: endDate)
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
    
    func deleteTrip(tripId: String) async throws {
        //TODO implement me
        throw NSError(domain: "Not implemented", code: 0, userInfo: nil)
    }
}
