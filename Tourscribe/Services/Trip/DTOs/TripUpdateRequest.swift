import Foundation
import Supabase

struct TripUpdateRequest {
    let name: String
    
    private static func isValidName(_ name: String) -> Bool {
        name.allSatisfy { $0.isLetter || $0.isNumber || $0.isWhitespace || $0 == "-" }
    }
    
    init(name: String) throws {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw TripValidationError.nameRequired
        }
        guard Self.isValidName(name) else {
            throw TripValidationError.invalidNameFormat
        }
        self.name = name
    }
    
    func toRPCParams(tripId: Int64) -> [String: AnyJSON] {
        [
            "p_trip_id": .integer(Int(tripId)),
            "p_name": .string(name)
        ]
    }
}
