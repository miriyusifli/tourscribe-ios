import Foundation

struct TripItemUpdateRequest: Encodable {
    let name: String
    let itemType: TripItemType
    let startTime: Date?
    let endTime: Date?
    let metadata: TripItemMetadata?

    enum CodingKeys: String, CodingKey {
        case name
        case itemType = "item_type"
        case startTime = "start_time"
        case endTime = "end_time"
        case metadata
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(itemType, forKey: .itemType)
        try container.encodeIfPresent(startTime, forKey: .startTime)
        try container.encodeIfPresent(endTime, forKey: .endTime)

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
            break
        }
    }
}
