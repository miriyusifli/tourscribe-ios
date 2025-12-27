import SwiftUI

struct TripListView: View {
    @ObservedObject var viewModel: MyTripsViewModel
    @State private var editingTrip: Trip?
    @State private var tripToDelete: Trip?

    var body: some View {
        ScrollView {
            listContent
        }
        .refreshable {
            await viewModel.fetchTrips(for: viewModel.selectedSegment)
        }
        .safeAreaInset(edge: .bottom) {
            TripListAddButton(viewModel: viewModel)
        }
        .sheet(item: $editingTrip) { trip in
            NavigationStack {
                UpdateTripView(trip: trip) { updatedTrip in
                    viewModel.updateTrip(updatedTrip)
                }
            }
        }
        .alert(String(localized: "alert.delete.trip.title", defaultValue: "Delete Trip"), isPresented: .init(
            get: { tripToDelete != nil },
            set: { if !$0 { tripToDelete = nil } }
        )) {
            Button(String(localized: "button.cancel"), role: .cancel) { }
            Button(String(localized: "button.delete"), role: .destructive) {
                if let trip = tripToDelete {
                    Task {
                        await viewModel.deleteTrip(tripId: String(trip.id))
                    }
                }
            }
        } message: {
            Text(String(localized: "alert.delete.trip.message", defaultValue: "Are you sure you want to delete this trip?"))
        }
    }

    @ViewBuilder
    private var listContent: some View {
        if viewModel.isLoading && viewModel.trips.isEmpty {
            RefreshLoadingView()
        } else if viewModel.trips.isEmpty {
            let message = viewModel.selectedSegment == .upcoming
                ? String(localized: "empty.upcoming", defaultValue: "No upcoming trips")
                : String(localized: "empty.past", defaultValue: "No past trips")
            EmptyStateView(imageName: "suitcase", message: message)
        } else {
            tripRows
        }
    }
    
    @ViewBuilder
    private var tripRows: some View {
        LazyVStack(spacing: StyleGuide.Spacing.standard) {
            ForEach(viewModel.trips) { trip in
                NavigationLink(value: trip) {
                    TripCardView(trip: trip)
                }
                .buttonStyle(.plain)
                .contextMenu {
                    Button {
                        editingTrip = trip
                    } label: {
                        Label(String(localized: "button.edit"), systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        tripToDelete = trip
                    } label: {
                        Label(String(localized: "button.delete"), systemImage: "trash")
                    }
                }
            }
        }
        .padding(.horizontal, StyleGuide.Padding.xlarge)
    }
}
