import SwiftUI

struct ActivityTimelineItemView: View {
    let item: TripItem
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        BaseTimelineItemView(item: item, onEdit: onEdit, onDelete: onDelete) { isExpanded in
            if let location = item.location {
                SingleLocationView(location: location, isExpanded: isExpanded, backgroundColor: item.itemType.lighterColor)
            }
            if isExpanded { metadataView }
        }
    }
    
    @ViewBuilder
    private var metadataView: some View {
        // TODO: Add activity-specific metadata display when ActivityMetadata properties are defined
        EmptyView()
    }
}
