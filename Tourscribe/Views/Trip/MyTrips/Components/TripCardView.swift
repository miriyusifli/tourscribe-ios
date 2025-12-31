import SwiftUI

struct TripCardView: View {
    let trip: Trip
    
    private func tripLabelText() -> String {
        if trip.isOngoing { return String(localized: "On Trip") }
        if trip.isPast, let days = trip.daysSinceEnd {
            if days == 0 { return String(localized: "Ended today") }
            if days <= 30 { return String(localized: "\(days) \(days == 1 ? "day" : "days") ago") }
            let months = days / 30
            if months < 12 { return String(localized: "\(months) \(months == 1 ? "month" : "months") ago") }
            let years = months / 12
            return String(localized: "\(years) \(years == 1 ? "year" : "years") ago")
        }
        if let days = trip.daysUntilStart {
            if days <= 30 { return String(localized: "In \(days) \(days == 1 ? "day" : "days")") }
            let months = days / 30
            if months < 12 { return String(localized: "In \(months) \(months == 1 ? "month" : "months")") }
            let years = months / 12
            return String(localized: "In \(years) \(years == 1 ? "year" : "years")")
        }
        return ""
    }
    
    @ViewBuilder
    private func tripLabel() -> some View {
        HStack(spacing: 6) {
            if trip.isOngoing {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
            }
            Text(tripLabelText())
        }
        .font(.subheadline)
        .fontWeight(.medium)
        .foregroundColor(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial.opacity(1))
        .environment(\.colorScheme, .dark)
        .clipShape(Capsule())
        .padding(12)
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ZStack(alignment: .bottom) {
                // Background Image
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
                
                // Glass Footer
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(trip.name)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Rectangle()
                            .fill(.white.opacity(0.2))
                            .frame(height: 1)
                        
                        if let start = trip.startDate, let end = trip.endDate {
                            HStack {
                                HStack(spacing: 4) {
                                    Image(systemName: "calendar")
                                    Text("\(start.formatted(.dateTime.month().day())) - \(end.formatted(.dateTime.month().day()))")
                                }
                                Spacer()
                                let nights = Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
                                HStack(spacing: 4) {
                                    Image(systemName: "moon.fill")
                                    Text("\(nights) nights")
                                }
                            }
                            .font(.subheadline)
                            .foregroundColor(.white)
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(.ultraThinMaterial.opacity(1))
                .environment(\.colorScheme, .dark)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(12)
            }
            
            tripLabel()
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    TripCardView(trip: Trip(
        id: 1,
        userId: UUID(),
        name: "Amalfi Coast Escape",
        imgUrl: "https://images.unsplash.com/photo-1605632491882-f129aa074767?ixid=M3w4NDk0MzZ8MHwxfHNlYXJjaHwxfHxTcGFpbiUyMHRyYXZlbCUyQ2NpdHklMkNuYXR1cmUlMkNoaXN0b3J5JTJDcHJvZmVzc2lvbmFsJTJDbm8tcGVyc29uJTJDbm8tYW5pbWFsfGVufDB8MXx8fDE3NjY5NjM2Mzh8MA&ixlib=rb-4.1.0",
        startDate: Date(),
        endDate: Date().addingTimeInterval(86400 * 70),
        version: 1,
        createdAt: Date(),
        updatedAt: nil
    ))
}
