import SwiftUI

struct TimelineItemView: View {
    let item: TripItem
    var displayDate: Date? = nil
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        Group {
            switch item.itemType {
            case .flight:
                FlightTimelineItemView(item: item, onEdit: onEdit, onDelete: onDelete)
            case .accommodation:
                AccommodationTimelineItemView(item: item, displayDate: displayDate, onEdit: onEdit, onDelete: onDelete)
            case .activity:
                ActivityTimelineItemView(item: item, onEdit: onEdit, onDelete: onDelete)
            case .restaurant:
                RestaurantTimelineItemView(item: item, onEdit: onEdit, onDelete: onDelete)
            case .transport:
                TransportTimelineItemView(item: item, onEdit: onEdit, onDelete: onDelete)
            }
        }
    }
}
