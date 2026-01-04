import SwiftUI
import MapKit

struct TripMapView: View {
    let tripId: Int64
    let tripName: String
    
    @State private var viewModel: TripItemViewModel
    @State private var selectedDisplayItemId: String?
    @State private var selectedDate: Date = Date()
    @State private var mapPosition: MapCameraPosition = .automatic
    
    private let calendar = Calendar.current
    
    init(tripId: Int64, tripName: String) {
        self.tripId = tripId
        self.tripName = tripName
        self._viewModel = State(initialValue: TripItemViewModel(tripId: tripId))
    }
    
    private var availableDates: [Date] {
        viewModel.itemsByDate.map { $0.date }
    }
    
    private var filteredDisplayItems: [TimelineDisplayItem] {
        viewModel.itemsByDate.first { calendar.isDate($0.date, inSameDayAs: selectedDate) }?.items ?? []
    }
    
    private var annotations: [TripMapAnnotation] {
        filteredDisplayItems.flatMap { displayItem in
            displayItem.item.locations.map { location in
                TripMapAnnotation(
                    coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                    title: location.name,
                    itemType: displayItem.item.itemType,
                    displayItemId: displayItem.id
                )
            }
        }
    }
    
    private var selectedDisplayItem: TimelineDisplayItem? {
        filteredDisplayItems.first { $0.id == selectedDisplayItemId }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            mapView
            selectedItemCard
        }
        .animation(.easeInOut(duration: 0.25), value: selectedDisplayItemId)
        .navigationTitle(tripName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .task {
            CLLocationManager().requestWhenInUseAuthorization()
            await viewModel.fetchAllItems()
            initializeSelectedDate()
            zoomToFitAnnotations()
        }
        .safeAreaInset(edge: .top) {
            dayPicker
        }
        .onChange(of: selectedDate) { _, _ in
            selectedDisplayItemId = nil
            zoomToFitAnnotations()
        }
    }
    
    private func initializeSelectedDate() {
        let today = calendar.startOfDay(for: Date())
        selectedDate = availableDates.first { calendar.isDate($0, inSameDayAs: today) } ?? availableDates.first ?? today
    }
    
    @ViewBuilder
    private var mapView: some View {
        Map(position: $mapPosition, selection: $selectedDisplayItemId) {
            UserAnnotation()
            
            ForEach(annotations) { annotation in
                Marker(annotation.title, systemImage: annotation.itemType.icon, coordinate: annotation.coordinate)
                    .tint(annotation.itemType.color)
                    .tag(annotation.displayItemId)
            }
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
    }
    
    private func zoomToFitAnnotations() {
        guard !annotations.isEmpty else { return }
        
        let coordinates = annotations.map { $0.coordinate }
        let latitudes = coordinates.map { $0.latitude }
        let longitudes = coordinates.map { $0.longitude }
        
        let center = CLLocationCoordinate2D(
            latitude: (latitudes.min()! + latitudes.max()!) / 2,
            longitude: (longitudes.min()! + longitudes.max()!) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: max((latitudes.max()! - latitudes.min()!) * 1.5, 0.02),
            longitudeDelta: max((longitudes.max()! - longitudes.min()!) * 1.5, 0.02)
        )
        
        withAnimation {
            mapPosition = .region(MKCoordinateRegion(center: center, span: span))
        }
    }
    
    @ViewBuilder
    private var selectedItemCard: some View {
        if let displayItem = selectedDisplayItem {
            TimelineItemView(displayItem: displayItem, onEdit: {}, onDelete: {})
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.xlarge))
                .shadow(radius: 10)
                .padding()
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .onTapGesture { selectedDisplayItemId = nil }
        }
    }
    
    @ViewBuilder
    private var dayPicker: some View {
        if !availableDates.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: StyleGuide.Spacing.medium) {
                    ForEach(availableDates, id: \.self) { date in
                        dayButton(for: date)
                    }
                }
                .padding(.horizontal)
            }
            .background(.ultraThinMaterial)
        }
    }
    
    private func dayButton(for date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)
        return Button {
            selectedDate = date
        } label: {
            VStack(spacing: 2) {
                Text(isToday ? String(localized: "map.day.today") : date.formatted(.dateTime.weekday(.abbreviated)))
                    .font(.caption2)
                Text(date.formatted(.dateTime.day()))
                    .font(.headline)
            }
            .frame(width: 44, height: 50)
            .background(isSelected ? Color.accentColor : Color.clear)
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.standard))
        }
    }
}

struct TripMapAnnotation: Identifiable, Hashable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
    let itemType: TripItemType
    let displayItemId: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: TripMapAnnotation, rhs: TripMapAnnotation) -> Bool {
        lhs.id == rhs.id
    }
}

#Preview {
    NavigationStack {
        TripMapView(tripId: 30, tripName: "Germany Trip")
    }
}
