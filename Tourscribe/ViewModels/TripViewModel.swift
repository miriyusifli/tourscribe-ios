import SwiftUI
import Combine

class TripViewModel: ObservableObject {
    @Published var items: [ItineraryItem] = []
    @Published var tripTitle: String = ""
    @Published var tripDates: String = ""
    @Published var weather: String = ""
    
    init() {
        loadSampleData()
    }
    
    private func loadSampleData() {
        tripTitle = "Trip to Paris"
        tripDates = "Oct 12 - Oct 18, 2025"
        weather = "18°C"
        
        items = [
            ItineraryItem(
                startTime: "09:00", endTime: "10:30",
                title: "Breakfast at Café de Flore",
                address: "172 Bd Saint-Germain",
                category: .food,
                notes: "Try the hot chocolate"
            ),
            ItineraryItem(
                startTime: "11:00", endTime: "13:00",
                title: "Louvre Museum Tour",
                address: "Rue de Rivoli, 75001",
                category: .museum,
                notes: "Meeting point at Pyramid"
            ),
            ItineraryItem(
                startTime: "13:30", endTime: "14:30",
                title: "Lunch at Le Jules Verne",
                address: "Eiffel Tower, 2nd Floor",
                category: .food,
                notes: "Reservation #4492"
            )
        ]
    }
    
    func addItem() {
        // TODO: Add new item logic
    }
    
    func deleteItem(at index: Int) {
        items.remove(at: index)
    }
    
    func editItem(_ item: ItineraryItem) {
        // TODO: Edit item logic
    }
}
