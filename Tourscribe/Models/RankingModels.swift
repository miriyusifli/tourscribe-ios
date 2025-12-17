import SwiftUI

struct UserProfile {
    let name: String
    let handle: String
    let rank: String
    let imageName: String
    let stats: [UserStat]
}

struct UserStat: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let icon: String
    let color: Color
}

struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let rank: Int
    let name: String
    let score: String
    let isCurrentUser: Bool
}
