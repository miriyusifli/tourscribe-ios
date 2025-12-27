import SwiftUI

struct HeaderButton: View {
    let icon: String
    let title: String
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HeaderButtonLabel(icon: icon, title: title, iconColor: iconColor)
        }
        .accessibilityElement(children: .combine)
    }
}

struct HeaderButtonLabel: View {
    let icon: String
    let title: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: StyleGuide.Spacing.standard) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(iconColor)
                .clipShape(RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.small, style: .continuous))
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
            Spacer()
        }
        .foregroundColor(.textPrimary)
        .padding(StyleGuide.Padding.standard)
        .background(iconColor.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.large)
                .stroke(iconColor.opacity(0.1), lineWidth: 1)
        )
    }
}
