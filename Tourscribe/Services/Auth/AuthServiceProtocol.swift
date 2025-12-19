import Foundation
import Auth

protocol AuthServiceProtocol {
    func signUp(email: String, password: String) async throws -> User
    func signIn(email: String, password: String) async throws -> User
    func signOut() async throws
    func getCurrentUser() async throws -> User?
    func updateProfile(userId: String, data: ProfileUpdateRequest) async throws
    func signInWithSocial(provider: SocialAuthProvider) async throws -> User
}
