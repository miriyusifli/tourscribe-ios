import SwiftUI

struct AccommodationTimelineItemView: View {
    let item: TripItem
    let displayMode: TimelineDisplayItem.DisplayMode
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    private var timeText: String {
        displayMode == .checkIn
            ? DateFormatters.shortTime.string(from: item.startDateTime)
            : DateFormatters.shortTime.string(from: item.endDateTime)
    }
    
    private var labelKey: String.LocalizationValue {
        displayMode == .checkIn ? "label.check_in" : "label.check_out"
    }
    
    var body: some View {
        BaseTimelineItemView(item: item, onEdit: onEdit, onDelete: onDelete) {
            HStack {
                Text(timeText)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(String(localized: labelKey))
                    .font(.caption2.weight(.medium))
                    .padding(.horizontal, StyleGuide.Padding.small)
                    .padding(.vertical, StyleGuide.Padding.small)
                    .background(item.itemType.lightColor)
                    .clipShape(RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.small))
                Spacer()
            }
            Divider()
            LocationRowView(location: item.location!, iconColor: item.itemType.color)
        }
    }
}


#Preview {
    AccommodationTimelineItemView(
        item: try! TripItem(
            id: 1,
            tripId: 1,
            name: "Hotel Bayerischer Hof",
            itemType: .accommodation,
            startDateTime: Date(),
            endDateTime: Date().addingTimeInterval(86400 * 3),
            metadata: .accommodation(AccommodationMetadata()),
            locations: [Location(sequence: 0, name: "Hotel Bayerischer Hof", address: "Promenadeplatz 2-6, 80333 Munich", latitude: 48.1397, longitude: 11.5735)]
        ),
        displayMode: .checkIn,
        onEdit: {},
        onDelete: {}
    )
    .padding()
}
