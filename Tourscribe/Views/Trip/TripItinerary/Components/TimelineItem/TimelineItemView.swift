import SwiftUI

struct TimelineItemView: View {
    let displayItem: TimelineDisplayItem
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        Group {
            switch displayItem.item.itemType {
            case .flight:
                FlightTimelineItemView(item: displayItem.item, onEdit: onEdit, onDelete: onDelete)
            case .accommodation:
                AccommodationTimelineItemView(item: displayItem.item, displayMode: displayItem.displayMode, onEdit: onEdit, onDelete: onDelete)
            case .activity:
                ActivityTimelineItemView(item: displayItem.item, onEdit: onEdit, onDelete: onDelete)
            case .restaurant:
                RestaurantTimelineItemView(item: displayItem.item, onEdit: onEdit, onDelete: onDelete)
            case .transport:
                TransportTimelineItemView(item: displayItem.item, onEdit: onEdit, onDelete: onDelete)
            }
        }
    }
}
