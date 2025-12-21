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

// MARK: - Itinerary Item

struct ItineraryItem: Identifiable {
    let id = UUID()
    let startTime: String
    let endTime: String
    let title: String
    let address: String
    let category: ActivityCategory
    let notes: String?
}