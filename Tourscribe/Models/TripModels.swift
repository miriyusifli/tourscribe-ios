import SwiftUI

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
