import Foundation
import Supabase

struct TripCreateRequest {
    let name: String
    let startDate: Date?
    let endDate: Date?
    
    private static func isValidName(_ name: String) -> Bool {
        name.allSatisfy { $0.isLetter || $0.isNumber || $0.isWhitespace || $0 == "-" }
    }
    
    init(name: String, startDate: Date?, endDate: Date?) throws {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw TripValidationError.nameRequired
        }
        guard Self.isValidName(name) else {
            throw TripValidationError.invalidNameFormat
        }
        if let start = startDate, let end = endDate, start > end {
            throw TripValidationError.invalidDateRange
        }
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
    }
    
    func toRPCParams() -> [String: AnyJSON] {
        [
            "p_name": .string(name),
            "p_start_date": startDate.map { .string(DateFormatters.iso8601Date.string(from: $0)) } ?? .null,
            "p_end_date": endDate.map { .string(DateFormatters.iso8601Date.string(from: $0)) } ?? .null
        ]
    }
}
