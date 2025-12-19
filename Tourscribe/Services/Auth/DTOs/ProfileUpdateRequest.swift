import Foundation

struct ProfileUpdateRequest: Codable {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let birthDate: String
    let gender: String
    let interests: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case birthDate = "birth_date"
        case gender
        case interests
    }
}
