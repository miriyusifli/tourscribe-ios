import SwiftUI


// MARK: - Main View

struct TripItineraryView: View {
    @State private var viewModel: TripItemViewModel
    let trip: Trip
    
    init(trip: Trip) {
        self.trip = trip
        self._viewModel = State(initialValue: TripItemViewModel(tripId: trip.id))
    }
    
    private var tripDates: String {
        guard let startDate = trip.startDate, let endDate = trip.endDate else { return "N/A" }
        return "\(DateFormatters.mediumStyle.string(from: startDate)) - \(DateFormatters.mediumStyle.string(from: endDate))"
    }
    
    var body: some View {
        AppView {
            ScrollView(showsIndicators: false) {
                if viewModel.isLoading && viewModel.tripItems.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    LazyVStack(spacing: StyleGuide.Spacing.xxlarge) {
                        headerSection
                        actionButtons
                        timelineSection
                    }
                    .padding(.horizontal, StyleGuide.Padding.large)
                }
            }
            .safeAreaInset(edge: .bottom) {
                addButton
            }
        }
        .task { await viewModel.fetchTripItems() }
        .alert(item: $viewModel.alert) { alert in
            Alert(title: Text(alert.title), message: Text(alert.message), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $viewModel.isShowingCreateSheet) { 
            NavigationStack {
                CreateTripItemView(tripId: trip.id) { newItem in
                    viewModel.tripItems.append(newItem)
                    viewModel.tripItems.sort { ($0.startTime ?? .distantPast) < ($1.startTime ?? .distantPast) }
                }
            }
        }
    }
    
    @ViewBuilder
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: StyleGuide.Spacing.medium) {
            HStack {
                Text(trip.name)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                Spacer()
            }
            
            HStack {
                Image(systemName: "calendar")
                Text(tripDates)
                    .foregroundColor(.textSecondary)
            }
            .font(.subheadline)
        }
        .padding(.top, StyleGuide.Padding.xxlarge) // Adjusted for visual top spacing
    }
    
    @ViewBuilder
    private var actionButtons: some View {
        HStack(spacing: StyleGuide.Spacing.large) {
            HeaderButton(icon: "sparkles", title: String(localized:"button.recommendations"), iconColor: .yellow) {
                // TODO: Recommendations Action
            }
            HeaderButton(icon: "map.fill", title: String(localized:"button.map_view"), iconColor: .green) {
                // TODO: Map View Action
            }
        }
    }
    
    @ViewBuilder
    private var timelineSection: some View {
        LazyVStack(spacing: 0) {
            ForEach(viewModel.tripItems) { item in
                TimelineItemView(item: item, onEdit: {
                    // TODO: Show edit view for item
                }, onDelete: {
                    Task {
                        await viewModel.deleteTripItem(itemId: item.id)
                    }
                })
            }
        }
        .padding(.top, StyleGuide.Padding.standard)
    }
    
    @ViewBuilder
    private var addButton: some View {
        HStack {
            Spacer()
            Button(action: { viewModel.isShowingCreateSheet = true }) {
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

// MARK: - Preview

struct TripItineraryView_Previews: PreviewProvider {
    static var previews: some View {
        let previewTrip = Trip(id: 1, userId: UUID(), name: "Trip to Tokyo", startDate: Date(), endDate: Date().addingTimeInterval(86400 * 7), createdAt: Date(), updatedAt: nil)
        TripItineraryView(trip: previewTrip)
    }
}
