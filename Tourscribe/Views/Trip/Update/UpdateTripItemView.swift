import SwiftUI

@MainActor
struct UpdateTripItemView: View {
    private enum LocationSearchType: Identifiable {
        case single, departure, arrival
        var id: Self { self }
    }
    
    var onComplete: ((TripItem) -> Void)?
    
    @State private var viewModel: UpdateTripItemViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var activeLocationSearch: LocationSearchType?
    
    init(tripItem: TripItem, onComplete: ((TripItem) -> Void)? = nil) {
        self.onComplete = onComplete
        self._viewModel = State(initialValue: UpdateTripItemViewModel(tripItem: tripItem))
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
        .navigationTitle(String(localized: "trip_item.update.title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(String(localized: "button.cancel")) { dismiss() }
            }
        }
        .sheet(item: $activeLocationSearch) { searchType in
            NavigationView {
                LocationSearchView(
                    location: locationBinding(for: searchType),
                    filter: viewModel.itemType.pointOfInterestFilter
                )
            }
        }
        .onChange(of: viewModel.updatedItem) { _, newItem in
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
            
            locationSection
            
            CustomDatePicker(
                title: String(localized: viewModel.itemType == .accommodation ? "trip_item.field.check_in_time" : "trip_item.field.start_time"),
                selection: $viewModel.startDateTime,
                displayedComponents: [.date, .hourAndMinute]
            )
            
            CustomDatePicker(
                title: String(localized: viewModel.itemType == .accommodation ? "trip_item.field.check_out_time" : "trip_item.field.end_time"),
                selection: $viewModel.endDateTime,
                displayedComponents: [.date, .hourAndMinute]
            )
        }
    }
    
    @ViewBuilder
    private var locationSection: some View {
        if viewModel.itemType.isMultiLocation {
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

    @ViewBuilder
    private var metadataSection: some View {
        switch viewModel.itemType {
        case .flight:
            CustomTextField(placeholder: String(localized: "trip_item.field.airline"), text: $viewModel.airline)
            CustomTextField(placeholder: String(localized: "trip_item.field.flight_number"), text: $viewModel.flightNumber)
        case .transport:
            CustomTextField(placeholder: String(localized: "trip_item.field.carrier"), text: $viewModel.carrier)
            CustomTextField(placeholder: String(localized: "trip_item.field.vehicle_number"), text: $viewModel.vehicleNumber)
        default:
            EmptyView()
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
                await viewModel.updateTripItem()
            }
        }
    }
}
