import SwiftUI

struct UpdateTripView: View {
    @State private var viewModel: UpdateTripViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(trip: Trip) {
        self._viewModel = State(initialValue: UpdateTripViewModel(trip: trip))
    }
    
    var body: some View {
        AppView {
            VStack(spacing: StyleGuide.Spacing.xlarge) {
                form
                errorMessage
                Spacer()
                saveButton
            }
            .padding(StyleGuide.Padding.xlarge)
        }
        .navigationTitle(String(localized: "trip.edit.title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(String(localized: "button.cancel")) {
                    dismiss()
                }
            }
        }
        .onChange(of: viewModel.updatedTrip) { _, trip in
            if trip != nil {
                dismiss()
            }
        }
    }

    @ViewBuilder
    private var form: some View {
        VStack(alignment: .leading, spacing: StyleGuide.Spacing.xlarge) {
            CustomTextField(
                placeholder: String(localized: "trip.name.placeholder"),
                text: $viewModel.name
            )
        }
    }

    @ViewBuilder
    private var errorMessage: some View {
        if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .foregroundColor(.red)
                .font(.caption)
                .padding(.horizontal)
        }
    }

    @ViewBuilder
    private var saveButton: some View {
        PrimaryActionButton(
            title: String(localized: "button.save"),
            isLoading: viewModel.isLoading,
            action: {
                Task {
                    await viewModel.updateTrip()
                }
            }
        )
    }
}
