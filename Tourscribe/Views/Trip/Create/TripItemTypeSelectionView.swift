import SwiftUI

struct TripItemTypeSelectionView: View {
    @Binding var selectedType: TripItemType
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(TripItemType.allCases, id: \.self) { type in
                Button(action: {
                    selectedType = type
                    dismiss()
                }) {
                    HStack(spacing: StyleGuide.Spacing.large) {
                        Image(systemName: type.icon)
                            .font(.title2)
                            .foregroundColor(type.color)
                            .frame(width: StyleGuide.IconSize.medium)
                        VStack(alignment: .leading, spacing: StyleGuide.Spacing.small) {
                            Text(type.localizedName)
                                .font(.headline)
                            Text(type.localizedDescription)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if selectedType == type {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.accentColor)
                                .font(.title2)
                        }
                    }
                    .padding(.vertical, StyleGuide.Spacing.medium)
                }
                .foregroundColor(.primary)
            }
            .listStyle(.plain)
            .navigationTitle(String(localized: "trip_item.type.selection.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "button.done")) { dismiss() }
                }
            }
        }
    }
}
