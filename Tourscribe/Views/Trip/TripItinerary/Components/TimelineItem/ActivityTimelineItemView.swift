import SwiftUI

struct ActivityTimelineItemView: View {
    let item: TripItem
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        BaseTimelineItemView(item: item, onEdit: onEdit, onDelete: onDelete) { isExpanded in
            if let location = item.location {
                SingleLocationView(location: location, isExpanded: isExpanded)
            }
            if isExpanded { metadataView }
        }
    }
    
    @ViewBuilder
    private var metadataView: some View {
        if case .activity(let data) = item.metadata, let desc = data.description {
            MetadataRowView(icon: "info.circle", text: desc)
        }
    }
}
