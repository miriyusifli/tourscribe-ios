import SwiftUI

struct SignInView: View {
    @State private var viewModel = SignInViewModel()
    
    var body: some View {
        AppView {
            VStack(spacing: StyleGuide.Spacing.xlarge) {
                Spacer()
                header
                Spacer()
                socialButtons
            }
            .padding(StyleGuide.Padding.large)
        }
        .loadingOverlay(isShowing: viewModel.isLoading, title: String(localized: "signin.loading.title"))
        .navigationBarHidden(true)
        .alert(item: $viewModel.alert) { alertType in
            Alert(
                title: Text(alertType.title),
                message: Text(alertType.message),
                dismissButton: .cancel(Text("OK"))
            )
        }
    }

    @ViewBuilder
    private var header: some View {
        Text(String(localized: "signin.welcome"))
            .font(.system(size: 34, weight: .bold, design: .rounded))
            .foregroundColor(.textPrimary)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    @ViewBuilder
    private var socialButtons: some View {
        VStack(spacing: StyleGuide.Spacing.large) {
            SocialButton(
                icon: "apple-logo",
                title: String(localized: "signin.apple"),
                backgroundColor: .black,
                foregroundColor: .white,
                action: viewModel.signInWithApple
            )
            
            SocialButton(
                icon: "google-logo",
                title: String(localized: "signin.google"),
                backgroundColor: .white,
                foregroundColor: .black,
                action: viewModel.signInWithGoogle
            )
        }
    }
}

#Preview {
    SignInView()
}
