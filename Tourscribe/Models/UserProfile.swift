import Foundation

struct UserProfile: Codable {
    let id: String
    let email: String
    var firstName: String
    var lastName: String
    var birthDate: Date
    var gender: String
    var interests: [String]
    var createdAt: Date
    var updatedAt: Date
}
