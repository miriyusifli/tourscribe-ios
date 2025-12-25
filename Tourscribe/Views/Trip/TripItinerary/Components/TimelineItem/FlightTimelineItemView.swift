import SwiftUI

struct FlightTimelineItemView: View {
    let item: TripItem
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    private var flightData: FlightMetadata? {
        if case .flight(let data) = item.metadata { return data }
        return nil
    }
    
    var body: some View {
        BaseTimelineItemView(item: item, onEdit: onEdit, onDelete: onDelete) { _ in
            routeSection
        }
    }
    
    @ViewBuilder
    private var routeSection: some View {
        if let dep = item.departureLocation, let arr = item.arrivalLocation {
            HStack(spacing: StyleGuide.Spacing.standard) {
                // Departure
                VStack(spacing: StyleGuide.Spacing.small) {
                    if let start = item.startTime {
                        Text(DateFormatters.shortTime.string(from: start))
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.primary)
                    }
                    Text(dep.name)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity)
                
                // Flight path with flight number
                VStack(spacing: StyleGuide.Spacing.small) {
                    if let flightNumber = flightData?.flightNumber {
                        Text(flightNumber)
                            .font(.caption.weight(.bold).monospaced())
                            .foregroundStyle(item.itemType.color)
                    }
                    
                    HStack(spacing: StyleGuide.Spacing.routePath) {
                        Circle()
                            .fill(item.itemType.color)
                            .frame(width: StyleGuide.Dimensions.routeDotSize, height: StyleGuide.Dimensions.routeDotSize)
                        
                        Rectangle()
                            .fill(item.itemType.color.opacity(0.3))
                            .frame(height: StyleGuide.Dimensions.routeLineHeight)
                        
                        Image(systemName: "airplane")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(item.itemType.color)
                        
                        Rectangle()
                            .fill(item.itemType.color.opacity(0.3))
                            .frame(height: StyleGuide.Dimensions.routeLineHeight)
                        
                        Circle()
                            .fill(item.itemType.color)
                            .frame(width: StyleGuide.Dimensions.routeDotSize, height: StyleGuide.Dimensions.routeDotSize)
                    }
                }
                
                // Arrival
                VStack(spacing: StyleGuide.Spacing.small) {
                    if let end = item.endTime {
                        Text(DateFormatters.shortTime.string(from: end))
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.primary)
                    }
                    Text(arr.name)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(StyleGuide.Padding.standard)
            .background(Color.lightGray)
            .clipShape(RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.small, style: .continuous))
        }
    }
}
