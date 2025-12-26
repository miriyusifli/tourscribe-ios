import SwiftUI

struct MyTrips: View {
    // MARK: - State
    @StateObject private var viewModel = MyTripsViewModel()
    @State private var navigationPath = NavigationPath()
    @State private var selectedTab = 0
    
    let user: UserProfile

    var body: some View {
        MainTabView(
            selection: $selectedTab,
            mainTabTitle: String(localized: "tab.my_trips"),
            mainTabIcon: "suitcase.fill",
            user: user
        ) {
            content
        }
    }

    @ViewBuilder
    private var content: some View {
        NavigationStack(path: $navigationPath) {
            AppView {
                VStack(spacing: StyleGuide.Spacing.xlarge) {
                    TripListHeaderView()
                    TripListPickerView(selectedSegment: $viewModel.selectedSegment)
                    TripListView(viewModel: viewModel)
                }
                .padding(.top, StyleGuide.Padding.standard)
            }
            .navigationDestination(for: Trip.self) { trip in
                TripItineraryView(trip: trip)
            }
        }
        .task(id: viewModel.selectedSegment) {
            await viewModel.fetchTrips(for: viewModel.selectedSegment)
        }
        .onChange(of: viewModel.isShowingCreateTrip) { _, newValue in
            if !newValue {
                Task {
                    await viewModel.fetchTrips(for: viewModel.selectedSegment)
                }
            }
        }
        .sheet(isPresented: $viewModel.isShowingCreateTrip) {
            NavigationStack {
                CreateTripView(navigationPath: $navigationPath)
            }
        }
        .alert(item: $viewModel.alert) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text(String(localized: "button.ok", defaultValue: "OK")))
            )
        }
    }
}
