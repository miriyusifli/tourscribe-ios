import Foundation

struct TimelineDisplayItem: Identifiable {
    let item: TripItem
    let displayMode: DisplayMode
    
    enum DisplayMode {
        case standard
        case checkIn
        case checkOut
    }
    
    private init(item: TripItem, displayMode: DisplayMode) {
        self.item = item
        self.displayMode = displayMode
    }
    
    var id: String {
        "\(item.id)-\(displayMode)"
    }
    
    var displayDate: Date {
        Calendar.current.startOfDay(for: displayMode == .checkOut ? item.endDateTime : item.startDateTime)
    }
    
    var sortTime: Date {
        displayMode == .checkOut ? item.endDateTime : item.startDateTime
    }
    
    static func from(_ item: TripItem) -> [TimelineDisplayItem] {
        guard item.itemType == .accommodation else {
            return [TimelineDisplayItem(item: item, displayMode: .standard)]
        }
        
        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: item.startDateTime)
        let endDay = calendar.startOfDay(for: item.endDateTime)
        
        return [
            TimelineDisplayItem(item: item, displayMode: .checkIn),
            TimelineDisplayItem(item: item, displayMode: .checkOut)
        ]
    }
}
