import Foundation
import Auth

protocol AuthServiceProtocol {
    func signUp(email: String, password: String) async throws -> User
    func signIn(email: String, password: String) async throws -> User
    func signOut() async throws
    func getCurrentUser() async throws -> User?
    func getProfile(userId: String) async throws -> UserProfile?
    func createProfile(data: ProfileCreateRequest) async throws -> UserProfile
    func updateProfile(userId: String, data: ProfileUpdateRequest) async throws
    func signInWithSocial(provider: SocialAuthProvider) async throws -> User
    
    var session: Session? { get async }
    var authStateChanges: AsyncStream<(event: AuthChangeEvent, session: Session?)> { get }
}
