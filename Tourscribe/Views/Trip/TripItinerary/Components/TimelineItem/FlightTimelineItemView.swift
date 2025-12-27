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
        BaseTimelineItemView(item: item, onEdit: onEdit, onDelete: onDelete) { _ in
            routeSection
        }
    }
    
    @ViewBuilder
    private var routeSection: some View {
        if let dep = item.departureLocation, let arr = item.arrivalLocation {
            VStack(spacing: StyleGuide.Spacing.none) {
                // Times and route line - always aligned
                HStack(spacing: StyleGuide.Spacing.standard) {
                    Text(DateFormatters.shortTime.string(from: item.startDateTime))
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                    
                    VStack(spacing: StyleGuide.Spacing.small) {
                        Text(flightData.flightNumber)
                            .font(.caption.weight(.bold).monospaced())
                            .foregroundStyle(item.itemType.color)
                        
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
                        
                        Text(flightData.airline)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(DateFormatters.shortTime.string(from: item.endDateTime))
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                }
                
                // Location names - can grow independently
                HStack(alignment: .top, spacing: StyleGuide.Spacing.standard) {
                    Text(dep.name)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                    
                    Spacer()
                        .frame(width: 80)
                    
                    Text(arr.name)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(StyleGuide.Padding.standard)
            .background(Color.lightGray)
            .clipShape(RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.small, style: .continuous))
        }
    }
}
