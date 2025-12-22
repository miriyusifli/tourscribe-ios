import SwiftUI

struct TimelineItemView: View {
    let item: TripItem
    @State private var isExpanded = false
    
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: StyleGuide.Spacing.standard) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: StyleGuide.Spacing.small) {
                    HStack(spacing: StyleGuide.Spacing.medium) {
                        if let startTime = item.startTime {
                            Text(DateFormatters.shortTime.string(from: startTime))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.textPrimary)
                        }
                        if item.startTime != nil && item.endTime != nil {
                            Text("-")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.textSecondary)
                        }
                        if let endTime = item.endTime {
                            Text(DateFormatters.shortTime.string(from: endTime))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.textPrimary)
                        }
                    }
                    .padding(.bottom, StyleGuide.Spacing.small)
                    
                    Text(item.name)
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    
                    if case let .accommodation(metadata) = item.metadata, let address = metadata.address {
                        Text(address)
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                }
                Spacer()
                Image(systemName: item.itemType.icon)
                    .font(.title2)
                    .foregroundColor(item.itemType.color)
            }
            
            Divider().background(Color.white.opacity(0.2))
            
            if case let .activity(metadata) = item.metadata, let description = metadata.description {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
                    .lineLimit(2)
            }
            
            if isExpanded {
                TimelineItemViewExpanded(onEdit: onEdit, onDelete: onDelete)
            }
        }
        .padding(StyleGuide.Padding.medium)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.xlarge))
        .overlay(
            RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.xlarge)
                .stroke(Color.glassBorder, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        .padding(.bottom, StyleGuide.Padding.medium)
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isExpanded.toggle()
            }
        }
    }
}

struct TimelineItemViewExpanded: View {
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        Group {
            Divider()
                .background(Color.white.opacity(0.3))
            
            HStack(spacing: StyleGuide.Spacing.large) {
                Button(action: { /* TODO: Open directions */ }) {
                    VStack(spacing: StyleGuide.Spacing.small) {
                        Image(systemName: "location.fill").font(.title3)
                        Text(String(localized: "button.directions")).font(.caption2)
                    }
                    .foregroundColor(.primaryColor)
                    .frame(maxWidth: .infinity)
                }
                
                Button(action: onEdit) {
                    VStack(spacing: StyleGuide.Spacing.small) {
                        Image(systemName: "pencil").font(.title3)
                        Text(String(localized: "button.edit")).font(.caption2)
                    }
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity)
                }
                
                Button(action: onDelete) {
                    VStack(spacing: StyleGuide.Spacing.small) {
                        Image(systemName: "trash").font(.title3)
                        Text(String(localized: "button.delete")).font(.caption2)
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}
