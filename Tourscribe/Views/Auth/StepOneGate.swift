import SwiftUI

struct StepOneGate: View {
    var body: some View {
        VStack(spacing: 16) {
            SocialButton(icon: "apple-logo", title: "Sign up with Apple", backgroundColor: .black, foregroundColor: .white)
            SocialButton(icon: "google-logo", title: "Sign up with Google", backgroundColor: .white, foregroundColor: .black)
            
            HStack(spacing: 12) {
                Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
                Text("or continue with email")
                    .font(.footnote)
                    .foregroundColor(.textSecondary)
                    .fixedSize()
                Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
            }
            .padding(.vertical, 20)
        }
    }
}

struct SocialButton: View {
    let icon: String
    let title: String
    let backgroundColor: Color
    let foregroundColor: Color
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 12) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}
