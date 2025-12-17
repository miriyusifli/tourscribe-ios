import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
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
                    profileHeader
                    settingsList
                }
                .padding(.horizontal)
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 80)
            }
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            Image(systemName: viewModel.user.imageName)
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
                        Text(viewModel.user.rank)
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
                Text(viewModel.user.name)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                
                Text(viewModel.user.handle)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(.top, 60)
    }
    
    private var settingsList: some View {
        VStack(spacing: 12) {
            SettingsRow(icon: "person.fill", title: "Edit Profile", color: .primaryColor)
            SettingsRow(icon: "lock.fill", title: "Privacy", color: Color(red: 0.2, green: 0.7, blue: 0.9))
            SettingsRow(icon: "questionmark.circle.fill", title: "Help & Support", color: Color(red: 0.2, green: 0.8, blue: 0.5))
            SettingsRow(icon: "arrow.right.square.fill", title: "Logout", color: Color(red: 0.9, green: 0.3, blue: 0.3))
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            .padding(16)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.glassBorder, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .accessibilityElement(children: .combine)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
