import SwiftUI

struct HeaderButton: View {
    let icon: String
    let title: String
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(iconColor)
                    .padding(StyleGuide.Spacing.small)
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.textPrimary)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 100)
            .padding(.vertical, StyleGuide.Padding.small)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.xxlarge))
            .overlay(
                RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.xxlarge)
                    .stroke(Color.glassBorder, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        }
        .accessibilityElement(children: .combine)
    }
}
