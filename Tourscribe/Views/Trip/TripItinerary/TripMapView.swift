import SwiftUI
import MapKit

struct TripMapView: View {
    let tripItems: [TripItem]
    let tripName: String
    @State private var selectedItemId: Int64?
    @State private var selectedDate: Date
    @State private var mapPosition: MapCameraPosition = .automatic
    
    private let calendar = Calendar.current
    
    private var availableDates: [Date] {
        let dates = Set(tripItems.map { calendar.startOfDay(for: $0.startDateTime) })
        return dates.sorted()
    }
    
    private var filteredItems: [TripItem] {
        tripItems.filter { calendar.isDate($0.startDateTime, inSameDayAs: selectedDate) }
    }
    
    private var annotations: [TripMapAnnotation] {
        filteredItems.flatMap { item in
            item.locations.map { location in
                TripMapAnnotation(
                    coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                    title: location.name,
                    itemType: item.itemType,
                    itemId: item.id
                )
            }
        }
    }
    
    private var selectedItem: TripItem? {
        tripItems.first { $0.id == selectedItemId }
    }
    
    init(tripItems: [TripItem], tripName: String) {
        self.tripItems = tripItems
        self.tripName = tripName
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dates = Set(tripItems.map { calendar.startOfDay(for: $0.startDateTime) })
        self._selectedDate = State(initialValue: dates.contains(today) ? today : dates.sorted().first ?? today)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            mapView
            selectedItemCard
        }
        .animation(.easeInOut(duration: 0.25), value: selectedItemId)
        .navigationTitle(tripName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            CLLocationManager().requestWhenInUseAuthorization()
            zoomToFitAnnotations()
        }
        .safeAreaInset(edge: .top) {
            dayPicker
        }
        .onChange(of: selectedDate) { _, _ in
            selectedItemId = nil
            zoomToFitAnnotations()
        }
    }
    
    @ViewBuilder
    private var mapView: some View {
        Map(position: $mapPosition, selection: $selectedItemId) {
            UserAnnotation()
            
            ForEach(annotations) { annotation in
                Marker(annotation.title, systemImage: annotation.itemType.icon, coordinate: annotation.coordinate)
                    .tint(annotation.itemType.color)
                    .tag(annotation.itemId)
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
        if let item = selectedItem {
            TimelineItemView(item: item, displayDate: item.startDateTime, onEdit: {}, onDelete: {})
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.xlarge))
                .shadow(radius: 10)
                .padding()
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .onTapGesture { selectedItemId = nil }
        }
    }
    
    private var dayPicker: some View {
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
    let itemId: Int64
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: TripMapAnnotation, rhs: TripMapAnnotation) -> Bool {
        lhs.id == rhs.id
    }
}

#Preview {
    let previewItems: [TripItem] = {
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
                "metadata": {},
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
    
    NavigationStack {
        TripMapView(tripItems: previewItems, tripName: "Germany Trip")
    }
}
