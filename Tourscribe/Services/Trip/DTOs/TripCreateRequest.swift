import Foundation

struct TripCreateRequest: Encodable {
    let userId: UUID
    let name: String
    let startDate: Date?
    let endDate: Date?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case name
        case startDate = "start_date"
        case endDate = "end_date"
    }
}
