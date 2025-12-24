import SwiftUI

struct Trip: Identifiable, Codable, Hashable {
    let id: Int64
    let userId: UUID
    let name: String
    let startDate: Date?
    let endDate: Date?
    let createdAt: Date
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case userId = "user_id"
        case startDate = "start_date"
        case endDate = "end_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
