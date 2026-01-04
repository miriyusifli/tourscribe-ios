import Foundation
import Supabase
import Auth

class AuthService: AuthServiceProtocol {
    private let client = SupabaseClientManager.shared.client
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    func getCurrentUser() async throws -> User? {
        return try await client.auth.session.user
    }
    
    func getProfile(userId: String) async throws -> UserProfile? {
        do {
            let response = try await client
                .from("profiles")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
            
            let profile = try JSONDecoders.iso8601.decode(UserProfile.self, from: response.data)
            return profile
        } catch {
            return nil
        }
    }
    
    func updateProfile(userId: String, data: ProfileUpdateRequest) async throws {
        do {
            try await client.rpc("update_profile", params: data.toRPCParams()).execute()
        } catch let error where error.localizedDescription.contains("VERSION_CONFLICT") {
            throw OptimisticLockError.versionConflict
        }
    }
    
    func createProfile(data: ProfileCreateRequest) async throws -> UserProfile {
        let response = try await client.rpc("create_profile", params: data.toRPCParams()).execute()
        return try JSONDecoders.iso8601.decode(UserProfile.self, from: response.data)
    }
    
    var session: Session? {
        get async {
            return try? await client.auth.session
        }
    }

    var authStateChanges: AsyncStream<(event: AuthChangeEvent, session: Session?)> {
        client.auth.authStateChanges
    }
    
    func signInWithSocial(provider: SocialAuthProvider) async throws -> User {
        let authProvider: Auth.Provider = provider == .google ? .google : .apple
        try await client.auth.signInWithOAuth(provider: authProvider, redirectTo: SupabaseConfig.redirectURL)
        return try await client.auth.session.user
    }
}
