import Foundation

// MARK: - Metadata Models

struct FlightMetadata: Codable, Hashable {
    let airline: String?
    let flightNumber: String?
}

struct AccommodationMetadata: Codable, Hashable {
    let checkIn: String?
    let checkOut: String?
}

struct ActivityMetadata: Codable, Hashable {
    let description: String?
}

struct RestaurantMetadata: Codable, Hashable {
    let cuisine: String?
}

struct TransportMetadata: Codable, Hashable {
    let carrier: String?
    let vehicleNumber: String?
}

enum TripItemMetadata: Hashable {
    case flight(FlightMetadata)
    case accommodation(AccommodationMetadata)
    case activity(ActivityMetadata)
    case restaurant(RestaurantMetadata)
    case transport(TransportMetadata)
}

// MARK: - TripItem Model

struct TripItem: Identifiable, Codable, Hashable {
    let id: Int64
    let tripId: Int64
    var name: String
    var itemType: TripItemType
    var startTime: Date?
    var endTime: Date?
    var metadata: TripItemMetadata?
    let createdAt: Date
    var updatedAt: Date?
    var locations: [Location]

    enum CodingKeys: String, CodingKey {
        case id, name, metadata
        case tripId = "trip_id"
        case itemType = "item_type"
        case startTime = "start_time"
        case endTime = "end_time"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case tripItemLocations = "trip_item_locations"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int64.self, forKey: .id)
        tripId = try container.decode(Int64.self, forKey: .tripId)
        name = try container.decode(String.self, forKey: .name)
        itemType = try container.decode(TripItemType.self, forKey: .itemType)
        startTime = try container.decodeIfPresent(Date.self, forKey: .startTime)
        endTime = try container.decodeIfPresent(Date.self, forKey: .endTime)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        
        // Decode locations from nested join
        if let nestedLocations = try container.decodeIfPresent([Location].self, forKey: .tripItemLocations) {
            locations = nestedLocations.sorted { $0.sequence < $1.sequence }
        } else {
            locations = []
        }
        
        // Decode metadata based on itemType
        if container.contains(.metadata) {
            switch itemType {
            case .flight:
                metadata = .flight(try container.decode(FlightMetadata.self, forKey: .metadata))
            case .accommodation:
                metadata = .accommodation(try container.decode(AccommodationMetadata.self, forKey: .metadata))
            case .activity:
                metadata = .activity(try container.decode(ActivityMetadata.self, forKey: .metadata))
            case .restaurant:
                metadata = .restaurant(try container.decode(RestaurantMetadata.self, forKey: .metadata))
            case .transport:
                metadata = .transport(try container.decode(TransportMetadata.self, forKey: .metadata))
            }
        } else {
            metadata = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(tripId, forKey: .tripId)
        try container.encode(name, forKey: .name)
        try container.encode(itemType, forKey: .itemType)
        try container.encodeIfPresent(startTime, forKey: .startTime)
        try container.encodeIfPresent(endTime, forKey: .endTime)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
        
        switch metadata {
        case .flight(let data):
            try container.encode(data, forKey: .metadata)
        case .accommodation(let data):
            try container.encode(data, forKey: .metadata)
        case .activity(let data):
            try container.encode(data, forKey: .metadata)
        case .restaurant(let data):
            try container.encode(data, forKey: .metadata)
        case .transport(let data):
            try container.encode(data, forKey: .metadata)
        case .none:
            break
        }
    }
}

// MARK: - Convenience Accessors

extension TripItem {
    /// Single location for non-multi-location types
    var location: Location? {
        locations.first
    }
    
    /// Departure location for flights/transport
    var departureLocation: Location? {
        locations.first { $0.sequence == 0 }
    }
    
    /// Arrival location for flights/transport
    var arrivalLocation: Location? {
        locations.first { $0.sequence == 1 }
    }
}
