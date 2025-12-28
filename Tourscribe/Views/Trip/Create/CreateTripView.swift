import SwiftUI

struct CreateTripView: View {
    @StateObject private var viewModel = CreateTripViewModel()
    @Environment(\.dismiss) private var dismiss
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        AppView {
            VStack(spacing: StyleGuide.Spacing.xlarge) {
                form
                errorMessage
                Spacer()
                createButton
            }
            .padding(StyleGuide.Padding.xlarge)
        }
        .navigationTitle(String(localized: "trip.create.title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(String(localized: "button.cancel")) {
                    dismiss()
                }
            }
        }
        .onChange(of: viewModel.createdTrip) { _, trip in
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
                text: $viewModel.tripName
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
    private var createButton: some View {
        PrimaryActionButton(
            title: String(localized: "trip.create.button"),
            isLoading: viewModel.isLoading,
            action: {
                Task {
                    await viewModel.createTrip()
                }
            }
        )
    }
}


struct CreateTripView_Previews: PreviewProvider {
    static var previews: some View {
        CreateTripView(navigationPath: .constant(NavigationPath()))
    }
}
