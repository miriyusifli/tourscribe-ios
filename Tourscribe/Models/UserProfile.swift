import Foundation

struct UserProfile: Codable {
    let id: String
    let email: String
    var firstName: String
    var lastName: String
    var birthDate: Date
    var gender: String
    var interests: [String]
    var version: Int
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, email, gender, interests, version
        case firstName = "first_name"
        case lastName = "last_name"
        case birthDate = "birth_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
