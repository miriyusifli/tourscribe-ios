import Foundation
import Supabase

struct TripCreateRequest {
    let name: String
    let startDate: Date?
    let endDate: Date?
    
    func toRPCParams() -> [String: AnyJSON] {
        [
            "p_name": .string(name),
            "p_start_date": startDate.map { .string(DateFormatters.iso8601Date.string(from: $0)) } ?? .null,
            "p_end_date": endDate.map { .string(DateFormatters.iso8601Date.string(from: $0)) } ?? .null
        ]
    }
}
