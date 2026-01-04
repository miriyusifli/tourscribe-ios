import Foundation
import Supabase

// MARK: - AnyJSON Conversion Extensions

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
        if let city = city {
            dict["city"] = .string(city)
        }
        if let country = country {
            dict["country"] = .string(country)
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
