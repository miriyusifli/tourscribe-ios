import Foundation
import MapKit
import Combine

class MapSearchService: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var searchQuery = ""
    @Published var completions: [MKLocalSearchCompletion] = []
    
    private var completer: MKLocalSearchCompleter
    private var cancellable: AnyCancellable?

    init(filter: MKPointOfInterestFilter? = nil) {
        self.completer = MKLocalSearchCompleter()
        super.init()
        self.completer.delegate = self
        
        if let filter = filter {
            self.completer.resultTypes = .pointOfInterest
            self.completer.pointOfInterestFilter = filter
        }
        
        cancellable = $searchQuery.assign(to: \.queryFragment, on: self.completer)
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.completions = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("MapSearchService completer failed with error: \(error.localizedDescription)")
    }
}
