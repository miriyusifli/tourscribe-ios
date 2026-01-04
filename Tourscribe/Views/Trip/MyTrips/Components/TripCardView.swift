import SwiftUI

struct TripCardView: View {
    let trip: Trip
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ZStack(alignment: .bottom) {
                tripImage
                tripFooter
            }
            
            if let label = trip.relativeTimeLabel {
                tripLabel(label)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.xlarge))
    }
    
    @ViewBuilder
    private var tripImage: some View {
        if let url = URL(string: trip.imgUrl) {
            CachedImage(url: url, size: CGSize(width: 400, height: 300))
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .clipped()
                .saturation(trip.isPast ? 0 : 1)
        } else {
            Color.gray.opacity(0.3)
                .frame(maxWidth: .infinity)
                .frame(height: 300)
        }
    }
    
    @ViewBuilder
    private var tripFooter: some View {
        HStack {
            VStack(alignment: .leading, spacing: StyleGuide.Spacing.medium) {
                Text(trip.name)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                if let start = trip.startDate, let end = trip.endDate {
                    Rectangle()
                        .fill(.white.opacity(0.2))
                        .frame(height: 1)
                    HStack {
                        HStack(spacing: StyleGuide.Spacing.small) {
                            Image(systemName: "calendar")
                            Text("\(start.formatted(.dateTime.month().day())) - \(end.formatted(.dateTime.month().day()))")
                        }
                        Spacer()
                        let nights = Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
                        HStack(spacing: StyleGuide.Spacing.small) {
                            Image(systemName: "moon.fill")
                            Text(String(localized: "trip.nights.\(nights)"))
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                }
            }
            Spacer()
        }
        .padding(.vertical, StyleGuide.Padding.medium)
        .padding(.horizontal, StyleGuide.Padding.large)
        .background(.ultraThinMaterial.opacity(1))
        .environment(\.colorScheme, .dark)
        .clipShape(RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.large))
        .padding(StyleGuide.Padding.standard)
    }
    
    private func tripLabel(_ text: String) -> some View {
        HStack(spacing: StyleGuide.Spacing.small) {
            if trip.isOngoing {
                Circle()
                    .fill(Color.green)
                    .frame(width: StyleGuide.Spacing.medium, height: StyleGuide.Spacing.medium)
            }
            Text(text)
        }
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundColor(.white)
        .padding(.horizontal, StyleGuide.Padding.standard)
        .padding(.vertical, StyleGuide.Padding.small)
        .background(.ultraThinMaterial.opacity(1))
        .environment(\.colorScheme, .dark)
        .clipShape(Capsule())
        .padding(StyleGuide.Padding.standard)
    }
}
