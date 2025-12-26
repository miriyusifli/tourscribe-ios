import SwiftUI

struct TripListView: View {
    @ObservedObject var viewModel: MyTripsViewModel
    @State private var editingTrip: Trip?

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
                        Task {
                            await viewModel.deleteTrip(tripId: String(trip.id))
                        }
                    } label: {
                        Label(String(localized: "button.delete"), systemImage: "trash")
                    }
                }
            }
        }
        .padding(.horizontal, StyleGuide.Padding.xlarge)
    }
}
