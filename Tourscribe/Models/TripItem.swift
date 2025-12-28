import Foundation

// MARK: - Metadata Models

struct FlightMetadata: Codable, Hashable {
    let airline: String
    let flightNumber: String
    
    enum CodingKeys: String, CodingKey {
        case airline
        case flightNumber = "flight_number"
    }
}

struct AccommodationMetadata: Codable, Hashable {
}

struct ActivityMetadata: Codable, Hashable {
}

struct RestaurantMetadata: Codable, Hashable {
}

struct TransportMetadata: Codable, Hashable {
    let carrier: String
    let vehicleNumber: String
    
    enum CodingKeys: String, CodingKey {
        case carrier
        case vehicleNumber = "vehicle_number"
    }
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
    var startDateTime: Date
    var endDateTime: Date
    var metadata: TripItemMetadata
    let version: Int
    let createdAt: Date
    var updatedAt: Date?
    var locations: [Location]

    enum CodingKeys: String, CodingKey {
        case id, name, metadata, version
        case tripId = "trip_id"
        case itemType = "item_type"
        case startDateTime = "start_datetime"
        case endDateTime = "end_datetime"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case tripItemLocations = "trip_item_locations"
    }
    
    init(
        id: Int64 = 0,
        tripId: Int64,
        name: String,
        itemType: TripItemType,
        startDateTime: Date,
        endDateTime: Date,
        metadata: TripItemMetadata,
        version: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date? = nil,
        locations: [Location] = []
    ) throws {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw TripItemValidationError.nameRequired
        }
        guard startDateTime <= endDateTime else {
            throw TripItemValidationError.invalidDateRange
        }
        guard !locations.isEmpty else {
            throw TripItemValidationError.locationRequired
        }
        if itemType == .flight && locations.count < 2 {
            throw TripItemValidationError.flightLocationsRequired
        }
        try Self.validateMetadata(metadata, for: itemType)
        self.id = id
        self.tripId = tripId
        self.name = name
        self.itemType = itemType
        self.startDateTime = startDateTime
        self.endDateTime = endDateTime
        self.metadata = metadata
        self.version = version
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.locations = locations
    }
    
    private static func validateMetadata(_ metadata: TripItemMetadata, for itemType: TripItemType) throws {
        switch itemType {
        case .flight:
            guard case .flight(let data) = metadata,
                  !data.airline.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !data.flightNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw TripItemValidationError.flightMetadataRequired
            }
        case .transport:
            guard case .transport(let data) = metadata,
                  !data.carrier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !data.vehicleNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw TripItemValidationError.transportMetadataRequired
            }
        case .accommodation, .activity, .restaurant:
            break
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int64.self, forKey: .id)
        tripId = try container.decode(Int64.self, forKey: .tripId)
        name = try container.decode(String.self, forKey: .name)
        itemType = try container.decode(TripItemType.self, forKey: .itemType)
        startDateTime = try container.decode(Date.self, forKey: .startDateTime)
        endDateTime = try container.decode(Date.self, forKey: .endDateTime)
        version = try container.decode(Int.self, forKey: .version)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        
        // Decode locations from nested join
        if let nestedLocations = try container.decodeIfPresent([Location].self, forKey: .tripItemLocations) {
            locations = nestedLocations.sorted { $0.sequence < $1.sequence }
        } else {
            locations = []
        }
        
        // Decode metadata based on itemType
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
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(tripId, forKey: .tripId)
        try container.encode(name, forKey: .name)
        try container.encode(itemType, forKey: .itemType)
        try container.encode(startDateTime, forKey: .startDateTime)
        try container.encode(endDateTime, forKey: .endDateTime)
        try container.encode(version, forKey: .version)
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
