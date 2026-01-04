import Foundation

struct Location: Identifiable, Codable, Hashable {
    let id: Int64?
    let tripItemId: Int64?
    let sequence: Int
    let name: String
    let address: String?
    let city: String?
    let country: String?
    let latitude: Double
    let longitude: Double
    let version: Int
    
    enum CodingKeys: String, CodingKey {
        case id, sequence, name, address, city, country, latitude, longitude, version
        case tripItemId = "trip_item_id"
    }
    
    init(sequence: Int, name: String, address: String?, city: String?, country: String?, latitude: Double, longitude: Double) {
        self.id = nil
        self.tripItemId = nil
        self.sequence = sequence
        self.name = name
        self.address = address
        self.city = city
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
        self.version = 0
    }
    
    func withSequence(_ sequence: Int) -> Location {
        Location(sequence: sequence, name: name, address: address, city: city, country: country, latitude: latitude, longitude: longitude)
    }
}
