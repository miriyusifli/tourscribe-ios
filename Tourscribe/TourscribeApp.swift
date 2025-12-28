import SwiftUI

@main
struct TourscribeApp: App {
    @State private var appViewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if appViewModel.isLoading {
                    LoadingView()
                } else {
                    if let userProfile = appViewModel.userProfile {
                        MyTrips(user: userProfile)
                            .transition(.opacity)
                    } else {
                        NavigationStack {
                            SignInView { profile in
                                appViewModel.userProfile = profile
                            }
                        }
                        .transition(.opacity)
                    }
                }
            }
            .preferredColorScheme(.light)
        }
    }
}
