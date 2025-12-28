import Foundation
import Supabase

struct ProfileCreateRequest: Codable {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let birthDate: Date
    let gender: String
    let interests: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case birthDate = "birth_date"
        case gender
        case interests
    }
    
    private static func isValidName(_ name: String) -> Bool {
        name.allSatisfy { $0.isLetter }
    }
    
    init(id: String, email: String, firstName: String, lastName: String, birthDate: Date, gender: String, interests: [String]) throws {
        if firstName.trimmingCharacters(in: .whitespaces).isEmpty {
            throw ProfileValidationError.emptyFirstName
        }
        if lastName.trimmingCharacters(in: .whitespaces).isEmpty {
            throw ProfileValidationError.emptyLastName
        }
        if !Self.isValidName(firstName) || !Self.isValidName(lastName) {
            throw ProfileValidationError.invalidNameFormat
        }
        if gender.trimmingCharacters(in: .whitespaces).isEmpty {
            throw ProfileValidationError.emptyGender
        }
        let age = Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
        if age < AppConfig.minimumSignupAge {
            throw ProfileValidationError.underAge
        }
        if interests.count < AppConfig.minimumInterests {
            throw ProfileValidationError.insufficientInterests
        }
        
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
        self.gender = gender
        self.interests = interests
    }
    
    func toRPCParams() -> [String: AnyJSON] {
        [
            "p_id": .string(id),
            "p_email": .string(email),
            "p_first_name": .string(firstName),
            "p_last_name": .string(lastName),
            "p_birth_date": .string(DateFormatters.iso8601Date.string(from: birthDate)),
            "p_gender": .string(gender),
            "p_interests": .array(interests.map { .string($0) })
        ]
    }
}
