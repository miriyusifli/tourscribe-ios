import Foundation

protocol ChatServiceProtocol {
    func sendMessage(_ message: String, history: [ChatRequest.ChatMessage], tripId: Int64, user: UserProfile) async throws -> ChatResponse
}
