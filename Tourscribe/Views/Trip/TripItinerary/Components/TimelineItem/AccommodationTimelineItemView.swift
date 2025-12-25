import SwiftUI

struct AccommodationTimelineItemView: View {
    let item: TripItem
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        BaseTimelineItemView(item: item, onEdit: onEdit, onDelete: onDelete) { isExpanded in
            checkInOutSection
            if let location = item.location {
                SingleLocationView(location: location, isExpanded: isExpanded)
            }
        }
    }
    
    @ViewBuilder
    private var checkInOutSection: some View {
        if item.startTime != nil || item.endTime != nil {
            HStack(spacing: 0) {
                // Check-in
                if let checkIn = item.startTime {
                    VStack(spacing: StyleGuide.Spacing.small) {
                        Image(systemName: "arrow.down.to.line")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.green)
                        Text(DateFormatters.mediumStyle.string(from: checkIn))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        Text(String(localized: "label.check_in"))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                // Divider
                if item.startTime != nil && item.endTime != nil {
                    Rectangle()
                        .fill(Color(.separator))
                        .frame(width: StyleGuide.Dimensions.dividerWidth, height: StyleGuide.Dimensions.dividerHeight)
                }
                
                // Check-out
                if let checkOut = item.endTime {
                    VStack(spacing: StyleGuide.Spacing.small) {
                        Image(systemName: "arrow.up.from.line")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.red)
                        Text(DateFormatters.mediumStyle.string(from: checkOut))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        Text(String(localized: "label.check_out"))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(StyleGuide.Padding.standard)
            .background(item.itemType.color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.small, style: .continuous))
        }
    }
}
