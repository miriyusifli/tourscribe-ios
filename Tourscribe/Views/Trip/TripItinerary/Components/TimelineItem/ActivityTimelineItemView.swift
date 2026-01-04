import SwiftUI

struct ActivityTimelineItemView: View {
    let item: TripItem
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        BaseTimelineItemView(item: item, onEdit: onEdit, onDelete: onDelete) {
            HStack {
                Text("\(DateFormatters.shortTime.string(from: item.startDateTime)) - \(DateFormatters.shortTime.string(from: item.endDateTime))")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Spacer()
            }
            Divider()
            if let location = item.location {
                LocationRowView(location: location, iconColor: item.itemType.color)
            }
        }
    }
}
