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
                    HStack(spacing: 16) {
                        Image(systemName: type.icon)
                            .font(.title2)
                            .foregroundColor(type.color)
                            .frame(width: 40)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(type.rawValue.capitalized)
                                .font(.headline)
                            Text(type.description)
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
                    .padding(.vertical, 8)
                }
                .foregroundColor(.primary)
            }
            .listStyle(.plain)
            .navigationTitle("Select Item Type")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
