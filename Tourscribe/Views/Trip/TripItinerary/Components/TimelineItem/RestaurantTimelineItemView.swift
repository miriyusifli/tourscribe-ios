import SwiftUI

struct RestaurantTimelineItemView: View {
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
    RestaurantTimelineItemView(
        item: try! TripItem(
            id: 1,
            tripId: 1,
            name: "Dinner at Hofbräuhaus",
            itemType: .restaurant,
            startDateTime: Date(),
            endDateTime: Date().addingTimeInterval(7200),
            metadata: .restaurant(RestaurantMetadata()),
            locations: [Location(sequence: 0, name: "Hofbräuhaus", address: "Platzl 9, 80331 Munich", latitude: 48.1376, longitude: 11.5799)]
        ),
        onEdit: {},
        onDelete: {}
    )
    .padding()
}
