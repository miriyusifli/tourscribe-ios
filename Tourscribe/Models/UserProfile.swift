import Foundation

struct UserProfile: Codable {
    let id: String
    let email: String
    var firstName: String
    var lastName: String
    var birthDate: Date
    var gender: String?
    var interests: [String]?
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case birthDate = "birth_date"
        case gender
        case interests
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
