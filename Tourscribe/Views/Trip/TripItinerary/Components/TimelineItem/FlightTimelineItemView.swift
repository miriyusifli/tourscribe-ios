import SwiftUI

struct FlightTimelineItemView: View {
    let item: TripItem
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    private var flightData: FlightMetadata {
        guard case .flight(let data) = item.metadata else {
            fatalError("FlightTimelineItemView requires flight metadata")
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
                    Text(flightData.flightNumber)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(item.itemType.color)
                    HStack(spacing: 0) {
                        Circle()
                            .fill(item.itemType.color)
                            .frame(width: 6, height: 6)
                        Rectangle()
                            .fill(item.itemType.color)
                            .frame(height: 1)
                        Image(systemName: "airplane")
                            .font(.caption)
                            .foregroundStyle(item.itemType.color)
                        Rectangle()
                            .fill(item.itemType.color)
                            .frame(height: 1)
                        Circle()
                            .fill(item.itemType.color)
                            .frame(width: 6, height: 6)
                    }
                    Text(flightData.airline)
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
    FlightTimelineItemView(
        item: try! TripItem(
            id: 1,
            tripId: 1,
            name: "Flight to Munich",
            itemType: .flight,
            startDateTime: Date(),
            endDateTime: Date().addingTimeInterval(9000),
            metadata: .flight(FlightMetadata(airline: "Lufthansa", flightNumber: "LH123")),
            locations: [
                Location(sequence: 0, name: "JFK International", address: "New York, USA", latitude: 40.6413, longitude: -73.7781),
                Location(sequence: 1, name: "Munich Airport", address: "Munich, Germany", latitude: 48.3537, longitude: 11.7750)
            ]
        ),
        onEdit: {},
        onDelete: {}
    )
    .padding()
}
