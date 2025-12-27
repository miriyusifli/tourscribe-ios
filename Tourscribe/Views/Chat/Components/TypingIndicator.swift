import SwiftUI
import Combine

struct TypingIndicator: View {
    @State private var animatingDot = 0
    private let timer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack(spacing: StyleGuide.Spacing.small) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.textSecondary)
                    .frame(width: 8, height: 8)
                    .opacity(animatingDot == index ? 1 : 0.4)
            }
        }
        .padding(StyleGuide.Padding.standard)
        .background(Color.lightGray)
        .clipShape(RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.large))
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                animatingDot = (animatingDot + 1) % 3
            }
        }
    }
}
