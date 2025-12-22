import SwiftUI

struct CreateTripItemView: View {
    let tripId: Int64
    var onComplete: ((TripItem) -> Void)? // Changed to be optional
    
    @State private var viewModel: CreateTripItemViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingTypeSelector = false
    
    init(tripId: Int64, onComplete: ((TripItem) -> Void)? = nil) {
        self.tripId = tripId
        self.onComplete = onComplete
        self._viewModel = State(initialValue: CreateTripItemViewModel(tripId: tripId))
    }
    
    var body: some View {
        AppView { // Using AppView to match CreateTripView's design
            VStack(spacing: StyleGuide.Spacing.large) {
                form
                errorMessageView
                Spacer()
                saveButton
            }
            .padding(StyleGuide.Padding.xlarge)
        }
        .navigationTitle("New Itinerary Item")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
        .sheet(isPresented: $isShowingTypeSelector) {
            TripTypeSelectionView(selectedType: $viewModel.selectedItemType)
        }
        .onChange(of: viewModel.createdItem) { _, newItem in
            if let newItem = newItem {
                onComplete?(newItem)
                dismiss()
            }
        }
    }

    @ViewBuilder
    private var form: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: StyleGuide.Spacing.large) {
                coreDetailsSection
                metadataSection
            }
        }
    }

    @ViewBuilder
    private var coreDetailsSection: some View {
        VStack(spacing: StyleGuide.Spacing.large) {
            CustomTextField(placeholder: "Item Name (e.g., 'Dinner at...')", text: $viewModel.name)
            
            HStack {
                Text("Item Type")
                    .font(.body)
                    .foregroundColor(.textPrimary)
                Spacer()
                Button(action: { isShowingTypeSelector = true }) {
                    HStack(spacing: 8) {
                        Image(systemName: viewModel.selectedItemType.icon)
                            .foregroundColor(viewModel.selectedItemType.color)
                        Text(viewModel.selectedItemType.rawValue.capitalized)
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(StyleGuide.Padding.medium)
            .background(Color.white)
            .cornerRadius(StyleGuide.CornerRadius.standard)

            CustomDatePicker(title: "Start Time", selection: $viewModel.startTime, displayedComponents: [.date, .hourAndMinute])
            
            Toggle(isOn: Binding(
                get: { viewModel.endTime != nil },
                set: { hasEndTime in
                    if hasEndTime {
                        viewModel.endTime = viewModel.startTime
                    } else {
                        viewModel.endTime = nil
                    }
                }
            )) {
                Text("Set End Time")
            }
            .tint(.primaryColor)

            if viewModel.endTime != nil {
                CustomDatePicker(title: "End Time", selection: Binding(
                    get: { viewModel.endTime ?? viewModel.startTime },
                    set: { viewModel.endTime = $0 }
                ), displayedComponents: [.date, .hourAndMinute])
            }
        }
    }

    @ViewBuilder
    private var metadataSection: some View {
        VStack(spacing: StyleGuide.Spacing.large) {
            switch viewModel.selectedItemType {
            case .flight:
                CustomTextField(placeholder: "Airline", text: Binding($viewModel.airline, replacingNilWith: ""))
                CustomTextField(placeholder: "Flight Number", text: Binding($viewModel.flightNumber, replacingNilWith: ""))
            case .accommodation:
                CustomTextField(placeholder: "Address", text: Binding($viewModel.address, replacingNilWith: ""))
            case .activity:
                CustomTextField(placeholder: "Description", text: Binding($viewModel.description, replacingNilWith: ""))
            case .restaurant:
                CustomTextField(placeholder: "Cuisine Type", text: Binding($viewModel.cuisine, replacingNilWith: ""))
            }
        }
    }

    @ViewBuilder
    private var errorMessageView: some View {
        if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
                .foregroundColor(.red)
                .font(.caption)
                .padding(.horizontal)
        }
    }

    @ViewBuilder
    private var saveButton: some View {
        PrimaryActionButton(title: "Save Item", isLoading: viewModel.isLoading) {
            Task {
                await viewModel.createTripItem()
            }
        }
    }
}

fileprivate extension Binding where Value: Equatable {
    init(_ source: Binding<Value?>, replacingNilWith nilValue: Value) {
        self.init(
            get: { source.wrappedValue ?? nilValue },
            set: { newValue in
                source.wrappedValue = (newValue == nilValue) ? nil : newValue
            }
        )
    }
}

struct CreateTripItemView_Previews: PreviewProvider {
    static var previews: some View {
        CreateTripItemView(tripId: 1)
    }
}
