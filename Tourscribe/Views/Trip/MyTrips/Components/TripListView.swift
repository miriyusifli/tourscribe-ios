import SwiftUI

struct TripListView: View {
    @ObservedObject var viewModel: MyTripsViewModel

    var body: some View {
        List {
            listContent
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .refreshable {
            await viewModel.fetchTrips(for: viewModel.selectedSegment)
        }
        .safeAreaInset(edge: .bottom) {
            TripListAddButton(viewModel: viewModel)
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
                TripCardView(trip: trip)
                NavigationLink(value: trip) {
                    EmptyView()
                }
                .opacity(0)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(role: .destructive) {
                    Task {
                        await viewModel.deleteTrip(tripId: String(trip.id))
                    }
                } label: {
                    Label(String(localized: "button.delete", defaultValue: "Delete"), systemImage: "trash.fill")
                }
                .tint(.red)

                Button {
                    // TODO: Implement trip editing logic
                    print("Edit trip: \(trip.name)")
                } label: {
                    Label(String(localized: "button.edit", defaultValue: "Edit"), systemImage: "pencil")
                }
                .tint(.blue)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: StyleGuide.Padding.standard, leading: StyleGuide.Padding.xlarge, bottom: StyleGuide.Padding.standard, trailing: StyleGuide.Padding.xlarge))
        }
    }
}
