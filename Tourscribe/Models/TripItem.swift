import Foundation


// MARK: - Metadata Models

struct FlightMetadata: Codable, Hashable {
    // TODO: Add specific properties for flight metadata
    let airline: String?
    let flightNumber: String?
}

struct AccommodationMetadata: Codable, Hashable {
    // TODO: Add specific properties for accommodation metadata
    let address: String?
}

struct ActivityMetadata: Codable, Hashable {
    // TODO: Add specific properties for activity metadata
    let description: String?
}

struct RestaurantMetadata: Codable, Hashable {
    // TODO: Add specific properties for restaurant metadata
    let cuisine: String?
}

enum TripItemMetadata: Hashable {
    case flight(FlightMetadata)
    case accommodation(AccommodationMetadata)
    case activity(ActivityMetadata)
    case restaurant(RestaurantMetadata)
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

    enum CodingKeys: String, CodingKey {
        case id, name, metadata
        case tripId
        case itemType
        case startTime
        case endTime
        case createdAt
        case updatedAt
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

        
        if container.contains(.metadata) {
                // Based on the itemType, decode the metadata object into the appropriate struct.
                switch itemType {
                case .flight:
                    metadata = .flight(try container.decode(FlightMetadata.self, forKey: .metadata))
                case .accommodation:
                    metadata = .accommodation(try container.decode(AccommodationMetadata.self, forKey: .metadata))
                case .activity:
                    metadata = .activity(try container.decode(ActivityMetadata.self, forKey: .metadata))
                case .restaurant:
                    metadata = .restaurant(try container.decode(RestaurantMetadata.self, forKey: .metadata))
                }
        } else {
                // If the 'metadata' key is not present, set metadata to nil.
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
        case .flight(let flightData):
            try container.encode(flightData, forKey: .metadata)
        case .accommodation(let accommodationData):
            try container.encode(accommodationData, forKey: .metadata)
        case .activity(let activityData):
            try container.encode(activityData, forKey: .metadata)
        case .restaurant(let restaurantData):
            try container.encode(restaurantData, forKey: .metadata)
        case .none:
            // If metadata is nil, do nothing, it will be omitted from the encoded JSON
            break
        }
    }
}
