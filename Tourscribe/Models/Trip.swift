import SwiftUI

// MARK: - Trip Model
struct Trip: Identifiable, Codable, Hashable {
    let id: Int64
    let userId: UUID
    let name: String
    let startDate: Date?
    let endDate: Date?
    let createdAt: Date
    let updatedAt: Date?
}