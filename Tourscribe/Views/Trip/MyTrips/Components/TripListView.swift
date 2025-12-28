import SwiftUI

struct TripListView: View {
    @ObservedObject var viewModel: MyTripsViewModel
    @State private var editingTrip: Trip?
    @State private var tripToDelete: Trip?

    var body: some View {
        List {
            listContent
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: StyleGuide.Padding.small, leading: StyleGuide.Padding.xlarge, bottom: StyleGuide.Padding.small, trailing: StyleGuide.Padding.xlarge))
                .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .refreshable {
            await viewModel.fetchTrips(for: viewModel.selectedSegment)
        }
        .safeAreaInset(edge: .bottom) {
            FloatingActionButton(action: { viewModel.isShowingCreateTrip = true })
        }
        .sheet(item: $editingTrip) { trip in
            NavigationStack {
                UpdateTripView(trip: trip)
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
                        await viewModel.deleteTrip(tripId: trip.id)
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
        ForEach(viewModel.trips) { trip in
            ZStack {
                NavigationLink(value: trip) { EmptyView() }.opacity(0)
                TripCardView(trip: trip)
            }
            .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.xlarge))
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
            .onAppear {
                if trip.id == viewModel.trips.last?.id {
                    Task { await viewModel.loadMore() }
                }
            }
        }
        
        if viewModel.isLoadingMore {
            ProgressView()
                .frame(maxWidth: .infinity)
                .listRowSeparator(.hidden)
        }
    }
}
