import SwiftUI
import MapKit

struct BaseTimelineItemView<Content: View>: View {
    let item: TripItem
    var onEdit: () -> Void
    var onDelete: () -> Void
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: StyleGuide.Spacing.standard) {
            headerView
            Divider()
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
    }
    
    // MARK: - Header View
    
    @ViewBuilder
    private var headerView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: StyleGuide.Spacing.small) {
                HStack(spacing: StyleGuide.Spacing.small) {
                    Image(systemName: item.itemType.icon)
                    Text(item.itemType.localizedName)
                }
                .font(.caption2)
                .foregroundStyle(item.itemType.color)
                
                Text(item.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .lineLimit(2)
            }
            Spacer()
        }
    }
}

// MARK: - Shared Components

struct LocationRowView: View {
    let location: Location
    var iconColor: Color = .secondary
    
    var body: some View {
        HStack {
            Text(location.address!)
                .foregroundStyle(.secondary)
            Spacer()
            Button {
                let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(
                    latitude: location.latitude,
                    longitude: location.longitude
                )))
                destination.name = location.name
                destination.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
            } label: {
                Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                    .font(.title)
                    .foregroundStyle(iconColor)
            }
            .buttonStyle(.plain)
        }
        .font(.subheadline.weight(.medium))
    }
}
