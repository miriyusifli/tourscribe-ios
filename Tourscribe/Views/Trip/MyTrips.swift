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
    @State private var selectedTab = 0

    var body: some View {
        MainTabView(
            selection: $selectedTab,
            mainTabTitle: String(localized: "tab.my_trips"),
            mainTabIcon: "suitcase.fill"
        ) {
            content
        }
    }

    @ViewBuilder
    private var content: some View {
        NavigationStack(path: $navigationPath) {
            AppView {
                VStack(spacing: StyleGuide.Spacing.xlarge) {
                    HeaderView()
                    PickerView(selectedSegment: $viewModel.selectedSegment)
                    TripListView(viewModel: viewModel)
                }
                .padding(.top, StyleGuide.Padding.standard)
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
        .navigationDestination(for: Trip.self) { trip in
            // TODO: Implement Trip Details View
            Text("Trip Details: \(trip.name)")
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

private struct HeaderView: View {
    var body: some View {
        HStack {
            Text(String(localized: "title.my_trips", defaultValue: "My Trips"))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
            
            Spacer()
        }
        .padding(.horizontal, StyleGuide.Padding.large)
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
        .padding(.horizontal, StyleGuide.Padding.large)
    }
}

private struct TripListView: View {
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
            AddButton(viewModel: viewModel)
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

private struct RefreshLoadingView: View {
    var body: some View {
        ProgressView()
            .frame(maxWidth: .infinity, alignment: .center)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .padding(.top, StyleGuide.Padding.xxlarge)
    }
}

private struct EmptyStateView: View {
    let imageName: String
    let message: String

    var body: some View {
        VStack(spacing: StyleGuide.Spacing.standard) {
            Image(systemName: imageName)
                .font(.system(size: 48))
                .foregroundColor(.textSecondary)
            Text(message)
                .font(.headline)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .padding(.top, 60)
    }
}

private struct AddButton: View {
    @ObservedObject var viewModel: MyTripsViewModel
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                viewModel.isShowingCreateTrip = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.primaryColor)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.trailing, StyleGuide.Padding.large)
            .padding(.bottom, StyleGuide.Padding.large)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}



#Preview {
    MyTrips()
}
