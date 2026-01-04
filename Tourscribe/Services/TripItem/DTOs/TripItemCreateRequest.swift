import Foundation
import Supabase

private let iso8601Formatter = ISO8601DateFormatter()

struct TripItemCreateRequest {
    let tripId: Int64
    let name: String
    let itemType: TripItemType
    let startDateTime: Date
    let endDateTime: Date
    let metadata: TripItemMetadata
    let locations: [Location]
    
    private static func isValidName(_ name: String) -> Bool {
        name.allSatisfy { $0.isLetter || $0.isNumber || $0.isWhitespace || $0 == "-" || $0 == "→" || $0 == "," || $0 == "." || $0 == "&" || $0 == "/" || $0 == "'" }
    }
    
    init(
        tripId: Int64,
        name: String,
        itemType: TripItemType,
        startDateTime: Date,
        endDateTime: Date,
        metadata: TripItemMetadata,
        locations: [Location]
    ) throws {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw TripItemValidationError.nameRequired
        }
        guard Self.isValidName(name) else {
            throw TripItemValidationError.invalidNameFormat
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
        
        self.tripId = tripId
        self.name = name
        self.itemType = itemType
        self.startDateTime = startDateTime
        self.endDateTime = endDateTime
        self.metadata = metadata
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
    
    func toRPCParams() -> [String: AnyJSON] {
        [
            "p_trip_id": .integer(Int(tripId)),
            "p_name": .string(name),
            "p_item_type": .string(itemType.rawValue),
            "p_start_datetime": .string(iso8601Formatter.string(from: startDateTime)),
            "p_end_datetime": .string(iso8601Formatter.string(from: endDateTime)),
            "p_metadata": metadata.toAnyJSON(),
            "p_locations": .array(locations.map { $0.toAnyJSON() })
        ]
    }
}
