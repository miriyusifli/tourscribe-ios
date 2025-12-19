import Foundation
import Supabase
import Auth

class AuthService: AuthServiceProtocol {
    private let client = SupabaseClientManager.shared.client
    
    func signUp(email: String, password: String) async throws -> User {
        let response = try await client.auth.signUp(email: email, password: password)
        return response.user
    }
    
    func signIn(email: String, password: String) async throws -> User {
        let response = try await client.auth.signIn(email: email, password: password)
        return response.user
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    func getCurrentUser() async throws -> User? {
        return try await client.auth.session.user
    }

    
    func updateProfile(userId: String, data: ProfileUpdateRequest) async throws {
        try await client.from("profiles")
            .insert(data)
            .execute()
    }
    
    func signInWithSocial(provider: SocialAuthProvider) async throws -> User {
        // TODO: Implement actual social auth with Supabase
        // For Apple: client.auth.signInWithIdToken(credentials: .init(provider: .apple, idToken: token))
        // For Google: client.auth.signInWithIdToken(credentials: .init(provider: .google, idToken: token))
        throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Social auth not implemented yet"])
    }
}
