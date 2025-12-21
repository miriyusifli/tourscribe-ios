import SwiftUI

enum TripListSegment: Int, CaseIterable, Identifiable {
    case upcoming = 0
    case past = 1
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .upcoming:
            return String(localized: "segment.trips", defaultValue: "Trips")
        case .past:
            return String(localized: "segment.past_trips", defaultValue: "Past Trips")
        }
    }
}

struct MyTrips: View {
    // MARK: - State
    @StateObject private var viewModel = MyTripsViewModel()
    @State private var navigationPath = NavigationPath()
    @State private var isShowingCreateTrip = false
    @State private var selectedSegment: TripListSegment = .upcoming
    @State private var selectedTab = 0

    var body: some View {
        MainTabView(
            selection: $selectedTab,
            mainTabTitle: String(localized: "tab.my_trips"),
            mainTabIcon: "suitcase.fill"
        ) {
            MyTripsContentView(
                viewModel: viewModel,
                navigationPath: $navigationPath,
                isShowingCreateTrip: $isShowingCreateTrip,
                selectedSegment: $selectedSegment
            )
        }
    }
}

private struct MyTripsContentView: View {
    @ObservedObject var viewModel: MyTripsViewModel
    @Binding var navigationPath: NavigationPath
    @Binding var isShowingCreateTrip: Bool
    @Binding var selectedSegment: TripListSegment

    var body: some View {
        NavigationStack(path: $navigationPath) {
            AppView {
                VStack(spacing: 24) {
                    HeaderView()
                    PickerView(selectedSegment: $selectedSegment)
                    TripListView(
                        viewModel: viewModel,
                        selectedSegment: $selectedSegment,
                        isShowingCreateTrip: $isShowingCreateTrip
                    )
                }
                .padding(.top, 10)
            }
        }
        .task(id: selectedSegment) { await loadData() }
        .onChange(of: isShowingCreateTrip) { oldValue, newValue in
            if !newValue { Task { await loadData() } }
        }
        .sheet(isPresented: $isShowingCreateTrip) {
            NavigationStack {
                CreateTripView(navigationPath: $navigationPath)
            }
        }
        .navigationDestination(for: Trip.self) { trip in
            Text(String(localized: "Trip Details: \(trip.name)"))
        }
        .alert(item: $viewModel.alert) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text(String(localized: "button.ok")))
            )
        }
    }

    private func loadData() async {
        await viewModel.fetchTrips(for: selectedSegment)
    }
}

private struct HeaderView: View {
    var body: some View {
        HStack {
            Text(String(localized: "title.my_trips", defaultValue: "My Trips"))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

private struct PickerView: View {
    @Binding var selectedSegment: TripListSegment

    private var selection: Binding<Int> {
        Binding(
            get: { selectedSegment.rawValue },
            set: { selectedSegment = TripListSegment(rawValue: $0) ?? .upcoming }
        )
    }

    var body: some View {
        CustomSegmentedPicker(
            selection: selection,
            items: TripListSegment.allCases.map { $0.title }
        )
        .frame(height: 42)
        .padding(.horizontal, 24)
    }
}

private struct TripListView: View {
    @ObservedObject var viewModel: MyTripsViewModel
    @Binding var selectedSegment: TripListSegment
    @Binding var isShowingCreateTrip: Bool

    var body: some View {
        List {
            if viewModel.isLoading && viewModel.trips.isEmpty {
                RefreshLoadingView()
            } else if viewModel.trips.isEmpty {
                EmptyStateView(selectedSegment: selectedSegment)
            } else {
                TripsListView(trips: viewModel.trips)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .refreshable {
            await viewModel.fetchTrips(for: selectedSegment)
        }
        .safeAreaInset(edge: .bottom) {
            AddButton(isShowingCreateTrip: $isShowingCreateTrip)
        }
    }
}

private struct RefreshLoadingView: View {
    var body: some View {
        ProgressView()
            .frame(maxWidth: .infinity, alignment: .center)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .padding(.top, 40)
    }
}

private struct EmptyStateView: View {
    let selectedSegment: TripListSegment

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "suitcase")
                .font(.system(size: 48))
                .foregroundColor(.textSecondary)
            Text(selectedSegment == .upcoming ? String(localized: "empty.upcoming") : String(localized: "empty.past"))
                .font(.headline)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .padding(.top, 60)
    }
}

private struct TripsListView: View {
    let trips: [Trip]

    var body: some View {
        ForEach(trips) { trip in
            NavigationLink(value: trip) {
                TripCardView(trip: trip)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 10, leading: 24, bottom: 10, trailing: 24))
        }
    }
}

private struct AddButton: View {
    @Binding var isShowingCreateTrip: Bool
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                isShowingCreateTrip = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.primaryColor)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}


#Preview {
    MyTrips()
}