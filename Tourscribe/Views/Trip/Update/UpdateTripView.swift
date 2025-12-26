import SwiftUI

struct UpdateTripView: View {
    @State private var viewModel: UpdateTripViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showDates: Bool
    var onComplete: ((Trip) -> Void)?
    
    init(trip: Trip, onComplete: ((Trip) -> Void)? = nil) {
        self._viewModel = State(initialValue: UpdateTripViewModel(trip: trip))
        self._showDates = State(initialValue: trip.startDate != nil)
        self.onComplete = onComplete
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
            if let trip {
                onComplete?(trip)
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
                viewModel.startDate = viewModel.startDate ?? Date()
                viewModel.endDate = viewModel.endDate ?? Calendar.current.date(byAdding: .day, value: 7, to: Date())
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
