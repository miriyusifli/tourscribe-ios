import SwiftUI

struct TripCardView: View {
    let trip: Trip
    
    var body: some View {
        VStack(alignment: .leading, spacing: StyleGuide.Spacing.standard) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: StyleGuide.Spacing.medium) {
                    Text(trip.name)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimary)
                        .lineLimit(2)
                    
                    HStack(spacing: StyleGuide.Spacing.medium) {
                        Image(systemName: "calendar")
                            .font(.caption)
                        Text(formattedDates)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.textSecondary)
                }
                
                Spacer()
                statusBadge
            }
        }
        .padding(StyleGuide.Padding.large)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.xlarge))
        .overlay(
            RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.xlarge)
                .stroke(Color.white.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 8)
    }
    
    private var formattedDates: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        if let start = trip.startDate, let end = trip.endDate {
            let startStr = formatter.string(from: start)
            let endStr = formatter.string(from: end)
            let year = Calendar.current.component(.year, from: start)
            return "\(startStr) - \(endStr), \(year)"
        } else if let start = trip.startDate {
            return formatter.string(from: start)
        }
        return "Dates TBD"
    }
    
    @ViewBuilder
    private var statusBadge: some View {
        if let status = tripStatus {
            switch status {
            case .current:
                HStack(spacing: StyleGuide.Spacing.medium) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: StyleGuide.Spacing.medium, height: StyleGuide.Spacing.medium)
                    Text(status.localizedName)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                .padding(.horizontal, StyleGuide.Padding.standard)
                .padding(.vertical, StyleGuide.Padding.small)
                .background(Color.green.opacity(0.1))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.green.opacity(0.2), lineWidth: 1)
                )
            case .past:
                Text(status.localizedName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal, StyleGuide.Padding.standard)
                    .padding(.vertical, StyleGuide.Padding.small)
                    .background(Color.black.opacity(0.05))
                    .clipShape(Capsule())
            case .upcoming:
                EmptyView()
            }
        }
    }
    
    private var tripStatus: TripStatus? {
        let now = Date()
        if let start = trip.startDate, let end = trip.endDate {
            if now >= start && now <= end {
                return .current
            } else if now > end {
                return .past
            } else {
                return .upcoming
            }
        } else if let start = trip.startDate {
            return now > start ? .past : .upcoming
        }
        return nil
    }
}
