import SwiftUI
import MapKit

struct BaseTimelineItemView<Content: View>: View {
    let item: TripItem
    var onEdit: () -> Void
    var onDelete: () -> Void
    @ViewBuilder let expandedContent: (Bool) -> Content
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: StyleGuide.Spacing.standard) {
            headerView
            expandedContent(isExpanded)
            if isExpanded { goToButton }
            chevronIndicator
        }
        .padding(StyleGuide.Padding.medium)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.large, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.large, style: .continuous)
                .stroke(Color(.separator).opacity(0.3), lineWidth: StyleGuide.Dimensions.borderWidth)
        )
        .contextMenu {
            Button(action: onEdit) {
                Label(String(localized: "button.edit"), systemImage: "pencil")
            }
            Button(role: .destructive, action: onDelete) {
                Label(String(localized: "button.delete"), systemImage: "trash")
            }
        }
        .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.large, style: .continuous))
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                isExpanded.toggle()
            }
        }
        .sensoryFeedback(.selection, trigger: isExpanded)
    }
    
    // MARK: - Header View
    
    @ViewBuilder
    private var headerView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: StyleGuide.Spacing.small) {
                Label(item.itemType.rawValue.capitalized, systemImage: item.itemType.icon)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(item.itemType.color)
                
                Text(item.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(isExpanded ? nil : 2)
            }
            
            Spacer()
            
            timeView
        }
    }
    
    // MARK: - Time View
    
    @ViewBuilder
    private var timeView: some View {
        VStack(alignment: .trailing, spacing: StyleGuide.Spacing.small) {
            Text(DateFormatters.shortTime.string(from: item.startDateTime))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
            
            Text(DateFormatters.shortTime.string(from: item.endDateTime))
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }
    
    // MARK: - Chevron Indicator
    
    @ViewBuilder
    private var chevronIndicator: some View {
        HStack {
            Spacer()
            Image(systemName: "chevron.down")
                .font(.caption2.weight(.medium))
                .foregroundStyle(.tertiary)
                .rotationEffect(.degrees(isExpanded ? 180 : 0))
            Spacer()
        }
    }
    
    // MARK: - Go To Button
    
    @ViewBuilder
    private var goToButton: some View {
        if let location = item.location {
            HStack {
                Spacer()
                Button {
                    let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(
                        latitude: location.latitude,
                        longitude: location.longitude
                    )))
                    destination.name = location.name
                    destination.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
                } label: {
                    Label(String(localized: "button.go_to"), systemImage: "arrow.triangle.turn.up.right.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, StyleGuide.Padding.medium)
                        .padding(.vertical, StyleGuide.Padding.small)
                        .background(Color.primaryColor)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .transition(.scale.combined(with: .opacity))
        }
    }
}

// MARK: - Shared Components

struct SingleLocationView: View {
    let location: Location
    let isExpanded: Bool
    var backgroundColor: Color = Color.lightGray
    
    var body: some View {
        VStack(alignment: .leading, spacing: StyleGuide.Spacing.small) {
            HStack(spacing: StyleGuide.Spacing.small) {
                Image(systemName: "location.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(location.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
            }
            
            if let address = location.address {
                Text(address)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(isExpanded ? nil : 1)
            }
        }
        .padding(StyleGuide.Padding.small)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.small, style: .continuous))
    }
}

struct MultiLocationView: View {
    let departure: Location
    let arrival: Location
    
    var body: some View {
        HStack(spacing: StyleGuide.Spacing.small) {
            Image(systemName: "location.fill")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(departure.name)
                .lineLimit(1)
            Image(systemName: "arrow.right")
                .font(.caption2)
            Text(arrival.name)
                .lineLimit(1)
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
    }
}

struct MetadataRowView: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: StyleGuide.Spacing.small) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
        }
        .font(.caption)
        .foregroundStyle(.tertiary)
    }
}
