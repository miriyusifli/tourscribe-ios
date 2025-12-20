import SwiftUI

struct SignInView: View {
    @State private var viewModel = SignInViewModel()
    @Environment(\.dismiss) private var dismiss
    var onSignInSuccess: () -> Void
    
    var body: some View {
        AppView {
            VStack(spacing: 24) {
                Text(String(localized: "signin.welcome"))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Form
                VStack(spacing: 20) {
                    CustomTextField(icon: "envelope.fill", placeholder: String(localized: "label.email"), text: $viewModel.email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    
                    CustomSecureField(icon: "lock.fill", placeholder: String(localized: "label.password"), text: $viewModel.password)
                }
                
                // Sign In Button
                Button(action: viewModel.signIn) {
                    Text(String(localized: "signin.button"))
                        .font(.system(size: 18, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.primaryColor)
                .clipShape(Capsule())
                
                Spacer()
                
                // Divider
                HStack(spacing: 12) {
                    Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
                    Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
                }
                .padding(.vertical, 10)
                
                // Social Buttons
                VStack(spacing: 16) {
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
                
                // Sign Up Link
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
                .padding(.top, 10)
            }
            .padding(24)
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
            if success {
                onSignInSuccess()
            }
        }
        .navigationDestination(isPresented: $viewModel.requiresProfileSetup) {
            if let userId = viewModel.userId {
                ProfileSetupView(userId: userId, email: viewModel.email, onSetupSuccess: onSignInSuccess)
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

#Preview {
    SignInView(onSignInSuccess: {})
}
