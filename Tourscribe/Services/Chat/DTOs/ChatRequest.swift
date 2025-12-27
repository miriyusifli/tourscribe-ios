import Foundation

struct ChatRequest: Encodable {
    let message: String
    let history: [ChatMessage]
    let tripId: Int64
    let name: String
    let gender: String
    let birthDate: Date
    let interests: [String]
    
    struct ChatMessage: Encodable {
        let role: String
        let content: String
    }
    
    enum CodingKeys: String, CodingKey {
        case message, history, name, gender, interests
        case tripId = "trip_id"
        case birthDate = "birth_date"
    }
}
