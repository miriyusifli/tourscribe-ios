import SwiftUI

@MainActor
struct CreateTripItemView: View {
    private enum LocationSearchType: Identifiable {
        case single, departure, arrival
        var id: Self { self }
    }
    
    let tripId: Int64
    var onComplete: ((TripItem) -> Void)?
    
    @State private var viewModel: CreateTripItemViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingTypeSelector = false
    @State private var activeLocationSearch: LocationSearchType?
    
    init(tripId: Int64, onComplete: ((TripItem) -> Void)? = nil) {
        self.tripId = tripId
        self.onComplete = onComplete
        self._viewModel = State(initialValue: CreateTripItemViewModel(tripId: tripId))
    }
    
    var body: some View {
        AppView {
            VStack(spacing: StyleGuide.Spacing.large) {
                form
                errorMessageView
                Spacer()
                saveButton
            }
            .padding(StyleGuide.Padding.xlarge)
        }
        .navigationTitle(String(localized: "trip_item.create.title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(String(localized: "button.cancel")) { dismiss() }
            }
        }
        .sheet(isPresented: $isShowingTypeSelector) {
            TripTypeSelectionView(selectedType: $viewModel.selectedItemType)
        }
        .sheet(item: $activeLocationSearch) { searchType in
            NavigationView {
                LocationSearchView(
                    location: locationBinding(for: searchType),
                    filter: viewModel.selectedItemType.pointOfInterestFilter
                )
            }
        }
        .onChange(of: viewModel.createdItem) { _, newItem in
            if let newItem = newItem {
                onComplete?(newItem)
                dismiss()
            }
        }
    }
    
    private func locationBinding(for type: LocationSearchType) -> Binding<Location?> {
        switch type {
        case .single: return $viewModel.location
        case .departure: return $viewModel.departureLocation
        case .arrival: return $viewModel.arrivalLocation
        }
    }

    private var form: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: StyleGuide.Spacing.large) {
                coreDetailsSection
                metadataSection
            }
        }
    }

    private var coreDetailsSection: some View {
        VStack(spacing: StyleGuide.Spacing.large) {
            CustomTextField(placeholder: String(localized: "trip_item.field.name"), text: $viewModel.name)
            
            HStack {
                Text(String(localized: "trip_item.field.type"))
                    .font(.body)
                    .foregroundColor(.textPrimary)
                Spacer()
                Button(action: { isShowingTypeSelector = true }) {
                    HStack(spacing: StyleGuide.Spacing.medium) {
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
            
            locationSection
            
            CustomDatePicker(title: String(localized: "trip_item.field.start_time"), selection: $viewModel.startTime, displayedComponents: [.date, .hourAndMinute])
            
            CustomDatePicker(title: String(localized: "trip_item.field.end_time"), selection: $viewModel.endTime, displayedComponents: [.date, .hourAndMinute])
        }
    }
    
    @ViewBuilder
    private var locationSection: some View {
        if viewModel.selectedItemType.isMultiLocation {
            locationButton(
                title: String(localized: "trip_item.field.departure"),
                location: viewModel.departureLocation,
                action: { activeLocationSearch = .departure }
            )
            locationButton(
                title: String(localized: "trip_item.field.arrival"),
                location: viewModel.arrivalLocation,
                action: { activeLocationSearch = .arrival }
            )
        } else {
            locationButton(
                title: String(localized: "trip_item.field.location"),
                location: viewModel.location,
                action: { activeLocationSearch = .single }
            )
        }
    }
    
    private func locationButton(title: String, location: Location?, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(location?.name ?? title)
                    .foregroundColor(location == nil ? .gray : .primary)
                Spacer()
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
            }
            .padding(StyleGuide.Padding.medium)
            .background(Color.white)
            .cornerRadius(StyleGuide.CornerRadius.small)
        }
    }

    private var metadataSection: some View {
        VStack(spacing: StyleGuide.Spacing.large) {
            switch viewModel.selectedItemType {
            case .flight:
                CustomTextField(placeholder: String(localized: "trip_item.field.airline"), text: Binding($viewModel.airline, replacingNilWith: ""))
                CustomTextField(placeholder: String(localized: "trip_item.field.flight_number"), text: Binding($viewModel.flightNumber, replacingNilWith: ""))
            case .accommodation:
                CustomTextField(placeholder: String(localized: "trip_item.field.check_in"), text: Binding($viewModel.checkIn, replacingNilWith: ""))
                CustomTextField(placeholder: String(localized: "trip_item.field.check_out"), text: Binding($viewModel.checkOut, replacingNilWith: ""))
            case .activity:
                CustomTextField(placeholder: String(localized: "trip_item.field.description"), text: Binding($viewModel.activityDescription, replacingNilWith: ""))
            case .restaurant:
                CustomTextField(placeholder: String(localized: "trip_item.field.cuisine"), text: Binding($viewModel.cuisine, replacingNilWith: ""))
            case .transport:
                CustomTextField(placeholder: String(localized: "trip_item.field.carrier"), text: Binding($viewModel.carrier, replacingNilWith: ""))
                CustomTextField(placeholder: String(localized: "trip_item.field.vehicle_number"), text: Binding($viewModel.vehicleNumber, replacingNilWith: ""))
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

    private var saveButton: some View {
        PrimaryActionButton(title: String(localized: "trip_item.button.save"), isLoading: viewModel.isLoading) {
            Task {
                await viewModel.createTripItem()
            }
        }
    }
}

#Preview {
    NavigationStack {
        CreateTripItemView(tripId: 1)
    }
}
