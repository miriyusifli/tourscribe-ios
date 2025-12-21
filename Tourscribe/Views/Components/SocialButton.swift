import SwiftUI

struct SocialButton: View {
    let icon: String
    let title: String
    let backgroundColor: Color
    let foregroundColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: StyleGuide.Spacing.standard) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, StyleGuide.Padding.medium)
            .background(backgroundColor)
            .clipShape(Capsule())
        }
    }
}
