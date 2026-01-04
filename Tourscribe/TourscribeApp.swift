import SwiftUI
import Supabase

@main
struct TourscribeApp: App {
    @State private var appViewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if appViewModel.isLoading {
                    LoadingView()
                } else if let userProfile = appViewModel.userProfile {
                    MyTrips(user: userProfile)
                        .transition(.opacity)
                } else if appViewModel.requiresProfileSetup,
                          let userId = appViewModel.sessionUserId,
                          let email = appViewModel.sessionEmail {
                    NavigationStack {
                        ProfileSetupView(
                            userId: userId,
                            email: email,
                            onSetupSuccess: appViewModel.onProfileCreated
                        )
                    }
                    .transition(.opacity)
                } else {
                    NavigationStack {
                        SignInView()
                    }
                    .transition(.opacity)
                }
            }
            .preferredColorScheme(.light)
            .onOpenURL { url in
                Task {
                    try? await SupabaseClientManager.shared.client.auth.session(from: url)
                }
            }
        }
    }
}
