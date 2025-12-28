import Foundation

protocol UnsplashServiceProtocol {
    func fetchImageUrl(query: String) async throws -> String
}
