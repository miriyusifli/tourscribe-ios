import SwiftUI

// MARK: - Ranking View
struct RankingView: View {
    @StateObject private var viewModel = RankingViewModel()
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.backgroundTop, .backgroundBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    headerSection
                    statsSection
                    leaderboardSection
                }
                .padding(.horizontal)
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 80)
            }
        }
    }
    
    private var headerSection: some View {
        ProfileHeaderView(user: viewModel.user)
            .padding(.top, 60)
    }
    
    private var statsSection: some View {
        StatsGridView(stats: viewModel.user.stats)
    }
    
    private var leaderboardSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Global Ranking")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.textPrimary)
                .padding(.leading, 4)
            
            LazyVStack(spacing: 12) {
                ForEach(viewModel.leaderboard) { entry in
                    LeaderboardRow(entry: entry)
                }
            }
        }
    }
}

// MARK: - Sub-Components

struct ProfileHeaderView: View {
    let user: UserProfile
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: user.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .foregroundColor(.textPrimary)
                .background(Circle().fill(.ultraThinMaterial))
                .overlay(alignment: .bottom) {
                    HStack {
                        Image(systemName: "crown.fill")
                            .font(.caption)
                            .foregroundColor(.primaryColor)
                        Text(user.rank)
                            .font(.caption.bold())
                            .foregroundColor(.textPrimary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.primaryColor.opacity(0.5), lineWidth: 1))
                    .offset(y: 10)
                }
                .padding(.bottom, 20)
            
            VStack(spacing: 4) {
                Text(user.name)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                
                Text(user.handle)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
        }
    }
}

struct StatsGridView: View {
    let stats: [UserStat]
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(stats) { stat in
                VStack(spacing: 8) {
                    Image(systemName: stat.icon)
                        .font(.title2)
                        .foregroundColor(stat.color)
                        .padding(10)
                    
                    VStack(spacing: 2) {
                        Text(stat.value)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.textPrimary)
                        Text(stat.title)
                            .font(.caption)
                            .foregroundColor(.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 120)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.glassBorder, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
        }
    }
}

struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    
    var body: some View {
        HStack(spacing: 16) {
            Text("\(entry.rank)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(entry.rank <= 3 ? .primaryColor : .textSecondary)
                .frame(width: 30)
            
            Image(systemName: "person.circle.fill")
                .font(.title)
                .foregroundColor(.textSecondary)
            
            Text(entry.name)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(entry.isCurrentUser ? .primaryColor : .textPrimary)
            
            Spacer()
            
            Text(entry.score)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.textSecondary)
        }
        .padding(16)
        .background {
            if entry.isCurrentUser {
                Color.primaryColor.opacity(0.1)
            } else {
                Rectangle().fill(.ultraThinMaterial)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    entry.isCurrentUser ? Color.primaryColor.opacity(0.5) : Color.glassBorder,
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Preview
struct RankingView_Previews: PreviewProvider {
    static var previews: some View {
        RankingView()
    }
}
