import SwiftUI
import MapKit
import Combine

@MainActor
class LocationSearchViewModel: ObservableObject {
    @Published var isSearching = false
    @Published private(set) var selectedLocation: Location?
    
    @Published private(set) var searchQuery = ""
    @Published private(set) var completions: [MKLocalSearchCompletion] = []
    
    private let mapSearchService: MapSearchService
    private var cancellables = Set<AnyCancellable>()
    
    init(filter: MKPointOfInterestFilter? = nil) {
        self.mapSearchService = MapSearchService(filter: filter)
        
        mapSearchService.$searchQuery
            .receive(on: RunLoop.main)
            .assign(to: &$searchQuery)
        
        mapSearchService.$completions
            .receive(on: RunLoop.main)
            .assign(to: &$completions)
    }
    
    func setSearchQuery(_ query: String) {
        mapSearchService.searchQuery = query
    }
    
    func selectCompletion(_ completion: MKLocalSearchCompletion) async -> Location? {
        isSearching = true
        defer { isSearching = false }
        
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            if let mapItem = response.mapItems.first {
                let location = mapItem.toLocation()
                selectedLocation = location
                return location
            }
        } catch {
            // TODO: Handle error appropriately
        }
        return nil
    }
    
    func clearSearch() {
        mapSearchService.searchQuery = ""
    }
}
