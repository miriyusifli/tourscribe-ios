import SwiftUI

struct AccommodationTimelineItemView: View {
    let item: TripItem
    let displayDate: Date?
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    private let isCheckInDay: Bool
    private let isCheckOutDay: Bool
    
    init(item: TripItem, displayDate: Date? = nil, onEdit: @escaping () -> Void, onDelete: @escaping () -> Void) {
        self.item = item
        self.displayDate = displayDate
        self.onEdit = onEdit
        self.onDelete = onDelete
        
        let calendar = Calendar.current
        self.isCheckInDay = displayDate.map { calendar.isDate($0, inSameDayAs: item.startDateTime) } ?? true
        self.isCheckOutDay = displayDate.map { calendar.isDate($0, inSameDayAs: item.endDateTime) } ?? true
    }
    
    var body: some View {
        BaseTimelineItemView(item: item, onEdit: onEdit, onDelete: onDelete) { isExpanded in
            checkInOutSection
            if let location = item.location {
                SingleLocationView(location: location, isExpanded: isExpanded, backgroundColor: item.itemType.lighterColor)
            }
        }
    }
    
    @ViewBuilder
    private var checkInOutSection: some View {
        HStack(spacing: 0) {
            if isCheckInDay {
                timeColumn(icon: "door.left.hand.open", color: .green, time: item.startDateTime, label: "label.check_in")
            }
            
            if isCheckInDay && isCheckOutDay {
                Rectangle()
                    .fill(Color(.separator))
                    .frame(width: StyleGuide.Dimensions.dividerWidth, height: StyleGuide.Dimensions.dividerHeight)
            }
            
            if isCheckOutDay {
                timeColumn(icon: "door.right.hand.open", color: .red, time: item.endDateTime, label: "label.check_out")
            }
        }
        .padding(StyleGuide.Padding.standard)
        .background(item.itemType.lightColor)
        .clipShape(RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.small, style: .continuous))
    }
    
    private func timeColumn(icon: String, color: Color, time: Date, label: String.LocalizationValue) -> some View {
        VStack(spacing: StyleGuide.Spacing.small) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
            Text(DateFormatters.shortTime.string(from: time))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
            Text(String(localized: label))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
