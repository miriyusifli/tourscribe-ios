import Foundation
import Supabase

class TripService: TripServiceProtocol {
    private let client = SupabaseClientManager.shared.client
    
    func createTrip(name: String, startDate: Date?, endDate: Date?) async throws -> Trip {
        let user = try await client.auth.session.user
        
        let request = TripCreateRequest(
            userId: user.id,
            name: name,
            startDate: startDate,
            endDate: endDate
        )
        
        let trip: Trip = try await client
            .from("trips")
            .insert(request)
            .select()
            .single()
            .execute()
            .value
            
        return trip
    }
    
    func fetchUpcomingTrips() async throws -> [Trip] {
        let user = try await client.auth.session.user
        let nowStr = DateFormatters.iso8601Date.string(from: Date())
        
        let trips: [Trip] = try await client
            .from("trips")
            .select()
            .eq("user_id", value: user.id)
            .or("end_date.gte.\(nowStr),end_date.is.null")
            .order("start_date", ascending: true)
            .execute()
            .value
            
        return trips
    }
    
    func fetchPastTrips() async throws -> [Trip] {
        let user = try await client.auth.session.user
        let nowStr = DateFormatters.iso8601Date.string(from: Date())
        
        let trips: [Trip] = try await client
            .from("trips")
            .select()
            .eq("user_id", value: user.id)
            .lt("end_date", value: nowStr)
            .order("start_date", ascending: false) // Past trips usually shown newest first
            .execute()
            .value
            
        return trips
    }
    
    func deleteTrip(tripId: String) async throws {
        try await client
            .from("trips")
            .delete()
            .eq("id", value: tripId)
            .execute()
    }
}
