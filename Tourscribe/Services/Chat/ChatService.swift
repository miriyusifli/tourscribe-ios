import Foundation
import Supabase

class ChatService: ChatServiceProtocol {
    private let client = SupabaseClientManager.shared.client
    
    func sendMessage(_ message: String, history: [ChatRequest.ChatMessage], tripId: Int64, user: UserProfile) async throws -> ChatResponse {
        let request = ChatRequest(
            message: message,
            history: history,
            tripId: tripId,
            name: user.firstName,
            gender: user.gender,
            birthDate: user.birthDate,
            interests: user.interests
        )
        
        return try await client.functions.invoke(
            "llm-chat",
            options: FunctionInvokeOptions(body: request),
            decode: { data, _ in
                try JSONDecoder().decode(ChatResponse.self, from: data)
            }
        )
    }
}
