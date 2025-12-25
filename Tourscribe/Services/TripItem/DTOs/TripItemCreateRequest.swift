import Foundation
import Supabase

private let iso8601Formatter = ISO8601DateFormatter()

struct TripItemCreateRequest {
    let tripItem: TripItem
    
    func toRPCParams() -> [String: AnyJSON] {
        [
            "p_trip_id": .integer(Int(tripItem.tripId)),
            "p_name": .string(tripItem.name),
            "p_item_type": .string(tripItem.itemType.rawValue),
            "p_start_datetime": .string(iso8601Formatter.string(from: tripItem.startDateTime)),
            "p_end_datetime": .string(iso8601Formatter.string(from: tripItem.endDateTime)),
            "p_metadata": tripItem.metadata.toAnyJSON(),
            "p_locations": .array(tripItem.locations.map { $0.toAnyJSON() })
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
