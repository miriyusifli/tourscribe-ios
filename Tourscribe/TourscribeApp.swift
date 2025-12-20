import SwiftUI

@main
struct TourscribeApp: App {
    @State private var isLoggedIn = false
    
    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                MyTrips()
                    .transition(.opacity)
            } else {
                NavigationStack {
                    SignInView {
                        withAnimation {
                            isLoggedIn = true
                        }
                    }
                }
            }
        }
    }
}
