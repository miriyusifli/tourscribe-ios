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
    
    func fetchTrips() async throws -> [Trip] {
        let user = try await client.auth.session.user
        
        let trips: [Trip] = try await client
            .from("trips")
            .select()
            .eq("user_id", value: user.id)
            .order("start_date", ascending: true)
            .execute()
            .value
            
        return trips
    }
}
