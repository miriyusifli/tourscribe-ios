import SwiftUI

struct TripListHeaderView: View {
    var body: some View {
        HStack {
            Text(String(localized: "title.my_trips", defaultValue: "My Trips"))
                .font(StyleGuide.Typography.largeTitle)
                .foregroundColor(.textPrimary)
            
            Spacer()
        }
        .padding(.horizontal, StyleGuide.Padding.large)
    }
}
