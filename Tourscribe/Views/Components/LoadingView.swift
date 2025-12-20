import SwiftUI

struct LoadingView: View {
    var title: String? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            GifImage("loading")
                .frame(width: 80, height: 80)
            
            if let title = title {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 30)
        .padding(.horizontal, 40)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
        )
    }
}

extension View {
    func loadingOverlay(isShowing: Bool, title: String? = nil) -> some View {
        ZStack {
            self
            
            if isShowing {
                Color.black.opacity(0.15)
                    .ignoresSafeArea()
                    .transition(.opacity)
                
                LoadingView(title: title)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: isShowing)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        LoadingView(title: "Loading your trip...")
    }
}
