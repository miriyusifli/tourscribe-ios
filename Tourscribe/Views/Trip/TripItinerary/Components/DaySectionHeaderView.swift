import SwiftUI

struct DaySectionHeaderView: View {
    let date: Date
    let isToday: Bool
    
    init(date: Date) {
        self.date = date
        self.isToday = Calendar.current.isDateInToday(date)
    }
    
    var body: some View {
        HStack(spacing: StyleGuide.Spacing.medium) {
            Text(DateFormatters.dayOfWeek.string(from: date))
                .fontWeight(.semibold)
            Text(DateFormatters.shortDate.string(from: date))

        }
        .font(.subheadline)
        .foregroundStyle(isToday ? Color.white : Color.textPrimary)
        .padding(.horizontal, StyleGuide.Padding.medium)
        .padding(.vertical, StyleGuide.Padding.small)
        .background(isToday ? Color.primaryColor : Color.lightGray)
        .clipShape(UnevenRoundedRectangle(bottomTrailingRadius: StyleGuide.CornerRadius.standard, topTrailingRadius: StyleGuide.CornerRadius.standard))
    }
}
