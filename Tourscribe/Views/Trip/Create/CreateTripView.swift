import SwiftUI

struct CreateTripView: View {
    @StateObject private var viewModel = CreateTripViewModel()
    @Environment(\.dismiss) private var dismiss
    @Binding var navigationPath: NavigationPath
    @State private var showDates: Bool = false
    
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
            
            dateToggle
            
            if showDates {
                datePickers
            }
        }
        .animation(.spring(), value: showDates)
    }

    @ViewBuilder
    private var dateToggle: some View {
        Toggle(isOn: $showDates) {
            Text(String(localized: "label.set_dates"))
                .font(.body)
                .foregroundColor(.textPrimary)
        }
        .tint(.primaryColor)
        .padding(.horizontal, StyleGuide.Padding.medium)
        .padding(.vertical, StyleGuide.Padding.medium)
        .background(Color.white)
        .cornerRadius(StyleGuide.CornerRadius.standard)
        .onChange(of: showDates) { _, newValue in
            if newValue {
                viewModel.startDate = Date()
                viewModel.endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
            } else {
                viewModel.startDate = nil
                viewModel.endDate = nil
            }
        }
    }

    @ViewBuilder
    private var datePickers: some View {
        VStack(spacing: StyleGuide.Spacing.standard) {
            CustomDatePicker(
                title: String(localized: "label.start_date"),
                selection: Binding(
                    get: { viewModel.startDate ?? Date() },
                    set: { viewModel.startDate = $0 }
                ),
                displayedComponents: [.date]
            )
            
            CustomDatePicker(
                title: String(localized: "label.end_date"),
                selection: Binding(
                    get: { viewModel.endDate ?? Date() },
                    set: { viewModel.endDate = $0 }
                ),
                displayedComponents: [.date]
            )
        }
        .transition(.move(edge: .top).combined(with: .opacity))
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
