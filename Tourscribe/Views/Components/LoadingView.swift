import SwiftUI

struct LoadingView: View {
    var title: String? = nil
    
    var body: some View {
        VStack(spacing: StyleGuide.Spacing.large) {
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
        .padding(.vertical, StyleGuide.Padding.large)
        .padding(.horizontal, StyleGuide.Padding.xlarge)
        .background(
            RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.xlarge)
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
