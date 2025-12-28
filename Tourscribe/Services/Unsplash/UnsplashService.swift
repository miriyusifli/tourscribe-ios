import Foundation
import Supabase

class UnsplashService: UnsplashServiceProtocol {
    private let client = SupabaseClientManager.shared.client
    
    func fetchImageUrl(query: String) async throws -> String {
        let request = UnsplashImageRequest(query: query)
        let result: UnsplashImageResponse = try await client.functions.invoke(
            "unsplash-image-fetch",
            options: FunctionInvokeOptions(body: request),
            decode: { data, _ in
                try JSONDecoder().decode(UnsplashImageResponse.self, from: data)
            }
        )
        return result.url
    }
}
