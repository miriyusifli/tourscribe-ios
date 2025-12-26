import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    
    init(user: UserProfile) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(user: user))
    }
    
    var body: some View {
        NavigationStack {
            AppView {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: StyleGuide.Spacing.xlarge) {
                        profileHeader
                        settingsList
                    }
                    .padding(.horizontal)
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 80)
                }
            }
            .alert(item: $viewModel.alert) { alertType in
                Alert(
                    title: Text(alertType.title),
                    message: Text(alertType.message),
                    dismissButton: .default(Text("OK"))
                )
            }
            .navigationDestination(isPresented: $viewModel.showEditProfile) {
                EditProfileView(user: viewModel.user) { updatedProfile in
                    viewModel.user = updatedProfile
                }
            }
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: StyleGuide.Spacing.medium) {
            Image(systemName: "person.circle.fill")
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
                        //TODO uncomment
//                        Text(viewModel.user.rank)
//                            .font(.caption.bold())
//                            .foregroundColor(.textPrimary)
                    }
                    .padding(.horizontal, StyleGuide.Padding.standard)
                    .padding(.vertical, StyleGuide.Padding.small)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.primaryColor.opacity(0.5), lineWidth: 1))
                    .offset(y: StyleGuide.Padding.standard)
                }
                .padding(.bottom, StyleGuide.Padding.large)
            
            VStack(spacing: StyleGuide.Spacing.small) {
                Text(viewModel.user.firstName)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
            }
        }
        .padding(.top, 60)
    }
    
    private var settingsList: some View {
        VStack(spacing: StyleGuide.Spacing.standard) {
            SettingsRow(icon: "person.fill", title: String(localized: "profile.settings.edit_profile"), color: .primaryColor, action: viewModel.editProfile)
            SettingsRow(icon: "arrow.right.square.fill", title: String(localized: "profile.settings.logout"), color: Color(red: 0.9, green: 0.3, blue: 0.3), action: viewModel.logout)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: StyleGuide.Spacing.large) {
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
            .padding(StyleGuide.Padding.medium)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.large))
            .overlay(
                RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.large)
                    .stroke(Color.glassBorder, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .accessibilityElement(children: .combine)
    }
}
