import SwiftUI
import Combine

class RankingViewModel: ObservableObject {
    @Published var user: UserProfile
    @Published var leaderboard: [LeaderboardEntry] = []
    
    init() {
        self.user = UserProfile(
            name: "Alex Wanderer",
            handle: "@alex_w",
            rank: "Gold",
            imageName: "person.crop.circle.fill",
            stats: [
                UserStat(title: "Countries", value: "12", icon: "globe.europe.africa.fill", color: Color(red: 0.2, green: 0.7, blue: 0.9)),
                UserStat(title: "Distance", value: "14k km", icon: "airplane.path.dotted", color: Color(red: 1.0, green: 0.6, blue: 0.3)),
                UserStat(title: "Trips", value: "8", icon: "map.fill", color: Color(red: 0.2, green: 0.8, blue: 0.5))
            ]
        )
        
        loadLeaderboard()
    }
    
    private func loadLeaderboard() {
        leaderboard = [
            LeaderboardEntry(rank: 1, name: "Sarah J.", score: "18,200 km", isCurrentUser: false),
            LeaderboardEntry(rank: 2, name: "Alex Wanderer", score: "14,050 km", isCurrentUser: true),
            LeaderboardEntry(rank: 3, name: "Mike Chen", score: "11,800 km", isCurrentUser: false),
            LeaderboardEntry(rank: 4, name: "Emma W.", score: "9,400 km", isCurrentUser: false)
        ]
    }
    
    func refreshLeaderboard() {
        // TODO: Fetch leaderboard from API
    }
}
