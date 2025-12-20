import Foundation

struct ProfileUpdateRequest: Codable {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let birthDate: Date
    let gender: String
    let interests: [String]

}
