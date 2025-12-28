import Foundation
import Supabase

struct TripCreateRequest {
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
    
    func toRPCParams(imgUrl: String) -> [String: AnyJSON] {
        [
            "p_name": .string(name),
            "p_img_url": .string(imgUrl)
        ]
    }
}
