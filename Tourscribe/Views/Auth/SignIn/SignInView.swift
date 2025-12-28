import SwiftUI

struct SignInView: View {
    @State private var viewModel = SignInViewModel()
    @Environment(\.dismiss) private var dismiss
    var onSignInSuccess: (UserProfile) -> Void
    
    var body: some View {
        AppView {
            VStack(spacing: StyleGuide.Spacing.xlarge) {
                header
                form
                signInButton
                
                Spacer()
                
                VStack {
                    divider
                    socialButtons
                    signUpLink
                }
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
        .onChange(of: viewModel.signInSuccess) { _, success in
            if success, let profile = viewModel.signedInProfile {
                onSignInSuccess(profile)
            }
        }
        .navigationDestination(isPresented: $viewModel.requiresProfileSetup) {
            if let userId = viewModel.userId {
                ProfileSetupView(userId: userId, email: viewModel.email, onSetupSuccess: onSignInSuccess)
                    .navigationBarBackButtonHidden(true)
            }
        }
    }

    @ViewBuilder
    private var header: some View {
        Text(String(localized: "signin.welcome"))
            .font(.system(size: 34, weight: .bold, design: .rounded))
            .foregroundColor(.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var form: some View {
        VStack(spacing: StyleGuide.Spacing.xlarge) {
            CustomTextField(icon: "envelope.fill", placeholder: String(localized: "label.email"), text: $viewModel.email)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
            
            CustomSecureField(icon: "lock.fill", placeholder: String(localized: "label.password"), text: $viewModel.password)
        }
    }

    @ViewBuilder
    private var signInButton: some View {
        Button(action: viewModel.signIn) {
            Text(String(localized: "signin.button"))
                .font(.system(size: 18, weight: .bold))
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, StyleGuide.Padding.medium)
        .background(Color.primaryColor)
        .clipShape(Capsule())
    }

    @ViewBuilder
    private var divider: some View {
        HStack(spacing: StyleGuide.Spacing.standard) {
            Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
            Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
        }
        .padding(.vertical, StyleGuide.Padding.small)
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

    @ViewBuilder
    private var signUpLink: some View {
        HStack {
            Text("Don't have an account?")
                .foregroundColor(.textSecondary)
            NavigationLink(destination: SignUpView(onSignUpSuccess: onSignInSuccess)) {
                Text("Sign Up")
                    .fontWeight(.bold)
                    .foregroundColor(.primaryColor)
            }
        }
        .font(.system(size: 16))
        .padding(.top, StyleGuide.Padding.small)
    }
}

#Preview {
    SignInView(onSignInSuccess: { _ in })
}
