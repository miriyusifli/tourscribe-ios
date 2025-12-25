import SwiftUI

struct TransportTimelineItemView: View {
    let item: TripItem
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    private var transportData: TransportMetadata? {
        if case .transport(let data) = item.metadata { return data }
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
                    Text(DateFormatters.shortTime.string(from: item.startDateTime))
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.primary)
                    Text(dep.name)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity)
                
                // Route path with vehicle number and carrier
                VStack(spacing: StyleGuide.Spacing.small) {
                    if let vehicleNumber = transportData?.vehicleNumber {
                        Text(vehicleNumber)
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
                        
                        Image(systemName: "bus.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(item.itemType.color)
                        
                        Rectangle()
                            .fill(item.itemType.color.opacity(0.3))
                            .frame(height: StyleGuide.Dimensions.routeLineHeight)
                        
                        Circle()
                            .fill(item.itemType.color)
                            .frame(width: StyleGuide.Dimensions.routeDotSize, height: StyleGuide.Dimensions.routeDotSize)
                    }
                    
                    if let carrier = transportData?.carrier {
                        Text(carrier)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Arrival
                VStack(spacing: StyleGuide.Spacing.small) {
                    Text(DateFormatters.shortTime.string(from: item.endDateTime))
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.primary)
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
