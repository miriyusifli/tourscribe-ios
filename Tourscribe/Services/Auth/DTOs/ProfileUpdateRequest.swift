import Foundation
import Supabase

struct ProfileUpdateRequest {
    let firstName: String
    let lastName: String
    let birthDate: Date
    let gender: String
    
    private static func isValidName(_ name: String) -> Bool {
        name.allSatisfy { $0.isLetter }
    }
    
    init(firstName: String, lastName: String, birthDate: Date, gender: String) throws {
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
        
        self.firstName = firstName
        self.lastName = lastName
        self.birthDate = birthDate
        self.gender = gender
    }
    
    func toRPCParams() -> [String: AnyJSON] {
        [
            "p_first_name": .string(firstName),
            "p_last_name": .string(lastName),
            "p_birth_date": .string(DateFormatters.iso8601Date.string(from: birthDate)),
            "p_gender": .string(gender)
        ]
    }
}
