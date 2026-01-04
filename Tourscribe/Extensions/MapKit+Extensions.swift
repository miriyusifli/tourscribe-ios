import MapKit

extension CLPlacemark {
    var formattedAddress: String? {
        [subThoroughfare, thoroughfare, locality, administrativeArea, postalCode, country]
            .compactMap { $0 }
            .joined(separator: ", ")
            .presence
    }
}

extension MKMapItem {
    func toLocation(sequence: Int = 0) -> Location {
        Location(
            sequence: sequence,
            name: name ?? String(localized: "location.unknown"),
            address: placemark.formattedAddress,
            city: placemark.locality,
            country: placemark.country,
            latitude: placemark.coordinate.latitude,
            longitude: placemark.coordinate.longitude
        )
    }
}

private extension String {
    var presence: String? {
        isEmpty ? nil : self
    }
}
