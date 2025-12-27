import Foundation

struct ChatResponse: Decodable {
    let type: ResponseType
    let content: String?
    let tool: String?
    let arguments: [String: AnyCodable]?
    let remainingRequests: Int?
    
    enum ResponseType: String, Decodable {
        case text
        case toolCall = "tool_call"
    }
    
    enum CodingKeys: String, CodingKey {
        case type, content, tool, arguments
        case remainingRequests = "remaining_requests"
    }
}

struct AnyCodable: Decodable {
    let value: Any
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            value = string
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else {
            value = ""
        }
    }
    
    var stringValue: String? { value as? String }
    var intValue: Int? { value as? Int }
}
