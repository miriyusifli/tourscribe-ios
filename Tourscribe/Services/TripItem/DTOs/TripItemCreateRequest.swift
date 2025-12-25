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
    
    func toRPCParams(locations: [Location]) -> [String: AnyJSON] {
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

// MARK: - AnyJSON Helpers

extension Location {
    func toAnyJSON() -> AnyJSON {
        var dict: [String: AnyJSON] = [
            "sequence": .integer(sequence),
            "name": .string(name),
            "latitude": .double(latitude),
            "longitude": .double(longitude)
        ]
        if let address = address {
            dict["address"] = .string(address)
        }
        return .object(dict)
    }
}

extension TripItemMetadata {
    func toAnyJSON() -> AnyJSON {
        let encoder = JSONEncoder()
        let data: Data
        
        switch self {
        case .flight(let m): data = (try? encoder.encode(m)) ?? Data()
        case .accommodation(let m): data = (try? encoder.encode(m)) ?? Data()
        case .activity(let m): data = (try? encoder.encode(m)) ?? Data()
        case .restaurant(let m): data = (try? encoder.encode(m)) ?? Data()
        case .transport(let m): data = (try? encoder.encode(m)) ?? Data()
        }
        
        guard let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return .null
        }
        
        var result: [String: AnyJSON] = [:]
        for (key, value) in dict {
            switch value {
            case let str as String: result[key] = .string(str)
            case let num as Int: result[key] = .integer(num)
            case let num as Double: result[key] = .double(num)
            case let bool as Bool: result[key] = .bool(bool)
            default: break
            }
        }
        return .object(result)
    }
}
