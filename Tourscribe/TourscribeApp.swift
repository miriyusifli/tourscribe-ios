import SwiftUI

@main
struct TourscribeApp: App {
    @State private var appViewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            if appViewModel.isLoading {
                LoadingView()
            } else {
                if appViewModel.isLoggedIn {
                    MyTrips()
                        .transition(.opacity)
                } else {
                    NavigationStack {
                        SignInView {
                            withAnimation {
                                appViewModel.isLoggedIn = true
                            }
                        }
                    }
                    .transition(.opacity)
                }
            }
        }
    }
}
