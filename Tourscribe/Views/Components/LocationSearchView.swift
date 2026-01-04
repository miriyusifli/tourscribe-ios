import SwiftUI
import MapKit

struct LocationSearchView: View {
    @StateObject private var mapSearchService: MapSearchService
    @Binding var location: Location?
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isSearching = false
    
    init(location: Binding<Location?>, filter: MKPointOfInterestFilter? = nil) {
        self._location = location
        self._mapSearchService = StateObject(wrappedValue: MapSearchService(filter: filter))
    }

    var body: some View {
        AppView {
            ZStack {
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("Search for a location", text: $mapSearchService.searchQuery)
                            .foregroundColor(.primary)
                        Button(action: {
                            mapSearchService.searchQuery = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .opacity(mapSearchService.searchQuery.isEmpty ? 0 : 1)
                        }
                    }
                    .padding(StyleGuide.Padding.medium)
                    .background(Color.white)
                    .cornerRadius(StyleGuide.CornerRadius.standard)
                    .padding(.horizontal)

                    List(mapSearchService.completions) { completion in
                        VStack(alignment: .leading) {
                            Text(completion.title)
                                .font(.headline)
                            Text(completion.subtitle)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            Task {
                                await didTapOnCompletion(completion)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
                
                if isSearching {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    ProgressView("Searching...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                        .background(Color.white)
                        .cornerRadius(StyleGuide.CornerRadius.standard)
                }
            }
        }
        .navigationTitle("Search Location")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func didTapOnCompletion(_ completion: MKLocalSearchCompletion) async {
        isSearching = true
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            if let mapItem = response.mapItems.first {
                let placemark = mapItem.placemark
                self.location = Location(
                    sequence: 0,
                    name: mapItem.name ?? "Unknown Location",
                    address: placemark.formattedAddress,
                    city: placemark.locality,
                    country: placemark.country,
                    latitude: placemark.coordinate.latitude,
                    longitude: placemark.coordinate.longitude
                )
                presentationMode.wrappedValue.dismiss()
            }
        } catch {
            print("Error conducting local search: \(error.localizedDescription)")
        }
        isSearching = false
    }
}

// For the List to work, MKLocalSearchCompletion needs to be Identifiable.
extension MKLocalSearchCompletion: Identifiable {
    public var id: String {
        "\(title)\(subtitle)"
    }
}

extension CLPlacemark {
    var formattedAddress: String? {
        [subThoroughfare, thoroughfare, locality, administrativeArea, postalCode, country]
            .compactMap { $0 }
            .joined(separator: ", ")
            .nilIfEmpty
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

#Preview {
    NavigationStack {
        LocationSearchView(location: .constant(nil))
    }
}
