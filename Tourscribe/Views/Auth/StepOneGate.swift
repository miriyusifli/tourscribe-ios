import SwiftUI

struct StepOneGate: View {
    var viewModel: SignUpViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            SocialButton(
                icon: "apple-logo",
                title: String(localized: "auth.button.apple"),
                backgroundColor: .black,
                foregroundColor: .white,
                action: viewModel.signUpWithApple
            )
            
            SocialButton(
                icon: "google-logo",
                title: String(localized: "auth.button.google"),
                backgroundColor: .white,
                foregroundColor: .black,
                action: viewModel.signUpWithGoogle
            )
            
            DividerView()
        }
    }
}

private struct DividerView: View {
    var body: some View {
        HStack(spacing: 12) {
            line
            Text(String(localized: "auth.divider.email"))
                .font(.footnote)
                .foregroundColor(.textSecondary)
                .fixedSize()
            line
        }
        .padding(.vertical, 20)
    }
    
    private var line: some View {
        Rectangle()
            .fill(Color.white.opacity(0.1))
            .frame(height: 1)
    }
}
