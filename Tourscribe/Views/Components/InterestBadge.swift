import SwiftUI

struct InterestBadge: View {
    let emoji: String
    let name: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: StyleGuide.Spacing.medium) {
                Text(emoji)
                    .font(.system(size: 40))
                    .scaleEffect(isSelected ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                
                Text(name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isSelected ? .white : .textPrimary)
                
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, StyleGuide.Padding.large)
            .background(
                RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.large)
                    .fill(isSelected ? Color.primaryColor : Color.white)
                    .shadow(
                        color: isSelected ? Color.primaryColor.opacity(0.4) : Color.black.opacity(0.05),
                        radius: isSelected ? StyleGuide.CornerRadius.standard : StyleGuide.CornerRadius.small,
                        x: 0,
                        y: isSelected ? StyleGuide.Spacing.medium : StyleGuide.Spacing.small
                    )
            )
        }
        .buttonStyle(BouncyButtonStyle())
    }
}

// MARK: - Helper Style
private struct BouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
