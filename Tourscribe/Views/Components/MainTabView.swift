import SwiftUI

struct MainTabView<MainContent: View>: View {
    @Binding var selection: Int
    let mainTabTitle: String
    let mainTabIcon: String
    let user: UserProfile
    @ViewBuilder let mainContent: () -> MainContent
    
    var body: some View {
        TabView(selection: $selection) {
            mainContent()
                .tabItem {
                    Label(mainTabTitle, systemImage: mainTabIcon)
                }
                .tag(0)
            
            // Placeholder for Ranking (Tag 1)
            // RankingView().tabItem { ... }.tag(1)
            
            ProfileView(user: user)
                .tabItem {
                    Label(String(localized: "tab.profile"), systemImage: "person.fill")
                }
                .tag(2)
        }
        .accentColor(.primaryColor)
    }
}
