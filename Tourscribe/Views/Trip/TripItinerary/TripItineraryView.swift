import SwiftUI


// MARK: - Main View

struct TripItineraryView: View {
    @State private var viewModel: TripItemViewModel
    @State private var editingItem: TripItem?
    @State private var itemToDelete: TripItem?
    @State private var isShowingCreateSheet = false
    @State private var showLLMChat = false
    private let tripId: Int64
    private var tripStore = TripStore.shared
    let user: UserProfile
    
    private var trip: Trip { tripStore.trip(for: tripId)! }
    
    init(trip: Trip, user: UserProfile) {
        self.tripId = trip.id
        self.user = user
        self._viewModel = State(initialValue: TripItemViewModel(tripId: trip.id))
    }
    
    init(trip: Trip, user: UserProfile, items: [TripItem]) {
        self.tripId = trip.id
        self.user = user
        self._viewModel = State(initialValue: TripItemViewModel(tripId: trip.id, items: items))
    }
    
    private var tripDates: String {
        guard let startDate = trip.startDate, let endDate = trip.endDate else { return "N/A" }
        return "\(DateFormatters.mediumStyle.string(from: startDate)) - \(DateFormatters.mediumStyle.string(from: endDate))"
    }
    
    var body: some View {
        AppView {
            VStack(spacing: StyleGuide.Spacing.standard) {
                if viewModel.isLoading && viewModel.tripItems.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    headerSection
                        .padding(.horizontal, StyleGuide.Padding.large)
                        .background(alignment: .bottom) {
                            ZStack {
                                if let url = URL(string: trip.imgUrl) {
                                    CachedImage(url: url, size: CGSize(width: UIScreen.main.bounds.width, height: 300))
                                        .frame(height: 300, alignment: .top)
                                        .clipped()
                                } else {
                                    Color.clear
                                }
                                Color.black.opacity(0.35)
                            }
                            .ignoresSafeArea(edges: .top)
                        }
                    actionButtons
                        .padding(.horizontal, StyleGuide.Padding.standard)
                    
                    List {
                        timelineSection
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: StyleGuide.Padding.small, leading: StyleGuide.Padding.large, bottom: StyleGuide.Padding.small, trailing: StyleGuide.Padding.large))
                            .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .refreshable {
                        await viewModel.fetchTripItems()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                FloatingActionButton(action: { isShowingCreateSheet = true })
            }
        }
        .task { 
            if viewModel.tripItems.isEmpty { await viewModel.fetchTripItems() }
        }
        .alert(item: $viewModel.alert) { alert in
            Alert(title: Text(alert.title), message: Text(alert.message), dismissButton: .default(Text(String(localized: "button.ok"))))
        }
        .sheet(isPresented: $isShowingCreateSheet, onDismiss: {
            Task { await viewModel.fetchTripItems() }
        }) { 
            NavigationStack {
                CreateTripItemView(tripId: tripId)
            }
        }
        .sheet(item: $editingItem, onDismiss: {
            Task { await viewModel.fetchTripItems() }
        }) { item in
            NavigationStack {
                UpdateTripItemView(tripItem: item)
            }
        }
        .alert(String(localized: "alert.delete.item.title", defaultValue: "Delete Item"), isPresented: .init(
            get: { itemToDelete != nil },
            set: { if !$0 { itemToDelete = nil } }
        )) {
            Button(String(localized: "button.cancel"), role: .cancel) { }
            Button(String(localized: "button.delete"), role: .destructive) {
                if let item = itemToDelete {
                    Task {
                        await viewModel.deleteTripItem(itemId: item.id)
                    }
                }
            }
        } message: {
            Text(String(localized: "alert.delete.item.message", defaultValue: "Are you sure you want to delete this item?"))
        }
    }
    
    @ViewBuilder
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: StyleGuide.Spacing.medium) {
            Text(trip.name)
                .font(StyleGuide.Typography.largeTitle)
                .foregroundStyle(Color.white)
            
            Label(tripDates, systemImage: "calendar")
                .font(.subheadline)
                .foregroundStyle(Color.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, StyleGuide.Padding.large)
        .padding(.bottom, StyleGuide.Padding.xxlarge)
    }
    
    @ViewBuilder
    private var actionButtons: some View {
        HStack(spacing: StyleGuide.Spacing.large) {
            HeaderButton(icon: "sparkles", title: String(localized:"button.ai_planner"), iconColor: .yellow) {
                showLLMChat = true
            }
            NavigationLink {
                TripMapView(tripId: trip.id, tripName: trip.name)
            } label: {
                HeaderButtonLabel(icon: "map.fill", title: String(localized:"button.map_view"), iconColor: .green)
            }
        }
        .sheet(isPresented: $showLLMChat, onDismiss: {
            Task { await viewModel.fetchTripItems() }
        }) {
            LLMChatView(tripId: trip.id, user: user)
        }
    }
    
    @ViewBuilder
    private var timelineSection: some View {
        if viewModel.tripItems.isEmpty {
            EmptyStateView(
                imageName: "airplane.up.forward.app.fill",
                message: String(localized: "empty.itinerary", defaultValue: "No items yet. Start planning your trip!")
            )
        } else {
            ForEach(viewModel.itemsByDate, id: \.date) { dayGroup in
                Section {
                    HStack {
                        DaySectionHeaderView(date: dayGroup.date)
                        
                        Spacer(minLength: StyleGuide.Spacing.small)
                        
                        if let activeAccommodation = viewModel.activeAccommodation(for: dayGroup.date) {
                            ActiveAccommodationBanner(name: activeAccommodation.location?.name ?? activeAccommodation.name)
                        }
                    }
                    .padding(.trailing, StyleGuide.Padding.standard)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    
                    ForEach(dayGroup.items) { displayItem in
                        TimelineItemView(displayItem: displayItem, onEdit: {
                            editingItem = displayItem.item
                        }, onDelete: {
                            itemToDelete = displayItem.item
                        })
                        .onAppear {
                            if displayItem.item.id == viewModel.tripItems.last?.id {
                                Task { await viewModel.loadMore() }
                            }
                        }
                    }
                }
            }
            
            if viewModel.isLoadingMore {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let items: [TripItem] = {
        let json = """
        [
            {
                "id": 1,
                "trip_id": 30,
                "name": "Flight to Munich",
                "item_type": "flight",
                "start_datetime": "2025-12-24T08:00:00Z",
                "end_datetime": "2025-12-24T10:30:00Z",
                "metadata": {"airline": "Lufthansa", "flight_number": "LH123"},
                "created_at": "2025-12-24T16:44:36Z",
                "updated_at": null,
                "trip_item_locations": [
                    {"id": 1, "trip_item_id": 1, "sequence": 0, "name": "JFK International", "address": "New York, USA", "latitude": 40.6413, "longitude": -73.7781},
                    {"id": 2, "trip_item_id": 1, "sequence": 1, "name": "Munich Airport", "address": "Munich, Germany", "latitude": 48.3537, "longitude": 11.7750}
                ]
            },
            {
                "id": 2,
                "trip_id": 30,
                "name": "Hotel Bayerischer Hof",
                "item_type": "accommodation",
                "start_datetime": "2025-12-24T14:00:00Z",
                "end_datetime": "2025-12-28T11:00:00Z",
                "metadata": {"check_in": "14:00", "check_out": "11:00"},
                "created_at": "2025-12-24T16:44:36Z",
                "updated_at": null,
                "trip_item_locations": [
                    {"id": 3, "trip_item_id": 2, "sequence": 0, "name": "Hotel Bayerischer Hof", "address": "Promenadeplatz 2-6, 80333 Munich", "latitude": 48.1397, "longitude": 11.5735}
                ]
            },
            {
                "id": 3,
                "trip_id": 30,
                "name": "Visit Marienplatz",
                "item_type": "activity",
                "start_datetime": "2025-12-24T16:00:00Z",
                "end_datetime": "2025-12-24T18:00:00Z",
                "metadata": {},
                "created_at": "2025-12-24T16:44:36Z",
                "updated_at": null,
                "trip_item_locations": [
                    {"id": 4, "trip_item_id": 3, "sequence": 0, "name": "Marienplatz", "address": "Marienplatz, 80331 Munich", "latitude": 48.1374, "longitude": 11.5755}
                ]
            },
            {
                "id": 4,
                "trip_id": 30,
                "name": "Dinner at Hofbräuhaus",
                "item_type": "restaurant",
                "start_datetime": "2025-12-24T19:00:00Z",
                "end_datetime": "2025-12-24T21:00:00Z",
                "metadata": {},
                "created_at": "2025-12-24T16:44:36Z",
                "updated_at": null,
                "trip_item_locations": [
                    {"id": 5, "trip_item_id": 4, "sequence": 0, "name": "Hofbräuhaus", "address": "Platzl 9, 80331 Munich", "latitude": 48.1376, "longitude": 11.5799}
                ]
            },
            {
                "id": 5,
                "trip_id": 30,
                "name": "Train to Neuschwanstein",
                "item_type": "transport",
                "start_datetime": "2025-12-25T09:00:00Z",
                "end_datetime": "2025-12-25T11:00:00Z",
                "metadata": {"carrier": "Deutsche Bahn", "vehicle_number": "RE 57432"},
                "created_at": "2025-12-24T16:44:36Z",
                "updated_at": null,
                "trip_item_locations": [
                    {"id": 6, "trip_item_id": 5, "sequence": 0, "name": "Munich Hauptbahnhof", "address": "Munich Central Station", "latitude": 48.1403, "longitude": 11.5600},
                    {"id": 7, "trip_item_id": 5, "sequence": 1, "name": "Füssen Station", "address": "Füssen, Germany", "latitude": 47.5692, "longitude": 10.7008}
                ]
            }
        ]
        """
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try! decoder.decode([TripItem].self, from: json.data(using: .utf8)!)
    }()
    
    TripItineraryView(
        trip: Trip(
            id: 30,
            userId: UUID(),
            name: "Germany Trip",
            imgUrl: "asdasd",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 7),
            version: 0,
            createdAt: Date(),
            updatedAt: nil
        ),
        user: UserProfile(id: "", email: "", firstName: "", lastName: "", birthDate: Date(), gender: "", interests: [], version:0, createdAt: Date(), updatedAt: Date()),
        items: items
    )
}
