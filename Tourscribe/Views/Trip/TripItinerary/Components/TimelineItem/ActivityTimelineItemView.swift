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


#Preview {
    ActivityTimelineItemView(
        item: try! TripItem(
            id: 1,
            tripId: 1,
            name: "Visit Marienplatz",
            itemType: .activity,
            startDateTime: Date(),
            endDateTime: Date().addingTimeInterval(7200),
            metadata: .activity(ActivityMetadata()),
            locations: [Location(sequence: 0, name: "Marienplatz", address: "Marienplatz, 80331 Munich", latitude: 48.1374, longitude: 11.5755)]
        ),
        onEdit: {},
        onDelete: {}
    )
    .padding()
}
