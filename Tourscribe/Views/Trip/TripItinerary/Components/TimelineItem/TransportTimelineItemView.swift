import SwiftUI

struct TransportTimelineItemView: View {
    let item: TripItem
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    private var transportData: TransportMetadata {
        guard case .transport(let data) = item.metadata else {
            fatalError("TransportTimelineItemView requires transport metadata")
        }
        return data
    }
    
    var body: some View {
        BaseTimelineItemView(item: item, onEdit: onEdit, onDelete: onDelete) {
            timeRow
            Divider()
            routeRow
        }
    }
    
    @ViewBuilder
    private var timeRow: some View {
        if let dep = item.departureLocation, let arr = item.arrivalLocation {
            HStack(alignment: .center) {
                VStack(spacing: StyleGuide.Spacing.small) {
                    Text(DateFormatters.shortTime.string(from: item.startDateTime))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(dep.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                
                VStack(spacing: StyleGuide.Spacing.small) {
                    Text(transportData.vehicleNumber ?? "")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(item.itemType.color)
                    HStack(spacing: 0) {
                        Circle()
                            .fill(item.itemType.color)
                            .frame(width: 6, height: 6)
                        Rectangle()
                            .fill(item.itemType.color)
                            .frame(height: 1)
                        Image(systemName: "bus.fill")
                            .font(.caption)
                            .foregroundStyle(item.itemType.color)
                        Rectangle()
                            .fill(item.itemType.color)
                            .frame(height: 1)
                        Circle()
                            .fill(item.itemType.color)
                            .frame(width: 6, height: 6)
                    }
                    Text(transportData.carrier ?? "")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                VStack(spacing: StyleGuide.Spacing.small) {
                    Text(DateFormatters.shortTime.string(from: item.endDateTime))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(arr.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    @ViewBuilder
    private var routeRow: some View {
        if let dep = item.departureLocation {
            LocationRowView(location: dep, iconColor: item.itemType.color)
        }
    }
}


#Preview {
    TransportTimelineItemView(
        item: try! TripItem(
            id: 1,
            tripId: 1,
            name: "Train to Neuschwanstein",
            itemType: .transport,
            startDateTime: Date(),
            endDateTime: Date().addingTimeInterval(7200),
            metadata: .transport(TransportMetadata(carrier: "Deutsche Bahn", vehicleNumber: "RE 57432")),
            locations: [
                Location(sequence: 0, name: "Munich Hauptbahnhof", address: "Munich Central Station", latitude: 48.1403, longitude: 11.5600),
                Location(sequence: 1, name: "Füssen Station", address: "Füssen, Germany", latitude: 47.5692, longitude: 10.7008)
            ]
        ),
        onEdit: {},
        onDelete: {}
    )
    .padding()
}
