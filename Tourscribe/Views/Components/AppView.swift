import SwiftUI

struct AppView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // Standard Background Gradient
            LinearGradient(
                colors: [.backgroundTop, .backgroundBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            content
        }
    }
}

#Preview {
    AppView {
        Text("Hello World")
            .foregroundColor(.white)
    }
}
