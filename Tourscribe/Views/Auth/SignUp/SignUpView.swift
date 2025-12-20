import SwiftUI

// MARK: - Main Sign-Up View
@MainActor
struct SignUpView: View {
    @State private var viewModel = SignUpViewModel()
    @Environment(\.dismiss) private var dismiss
    var onSignUpSuccess: () -> Void
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        AppView {
            VStack(spacing: 25) {
                // Header
                Text(String(localized: "signup.credentials.title"))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Credentials Form
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        CustomTextField(icon: "envelope.fill", placeholder: String(localized: "label.email"), text: $viewModel.email)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled(true)
                        
                        if !viewModel.email.isEmpty && !viewModel.isEmailValid {
                            Text(String(localized: "validation.email.invalid.generic"))
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.leading, 4)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        CustomSecureField(icon: "lock.fill", placeholder: String(localized: "label.password"), text: $viewModel.password)
                        
                        if !viewModel.password.isEmpty {
                            HStack(spacing: 6) {
                                Text(LocalizedStringKey(viewModel.passwordStrength.label))
                                    .font(.caption)
                                    .foregroundColor(viewModel.passwordStrength.color)
                                
                                HStack(spacing: 4) {
                                    ForEach(0..<3) { index in
                                        Capsule()
                                            .fill(index < viewModel.passwordStrength.level ? viewModel.passwordStrength.color : Color.white.opacity(0.2))
                                            .frame(width: 30, height: 4)
                                    }
                                }
                            }
                            .padding(.leading, 4)
                        }
                    }
                }
                
                Spacer()
                
                // Footer Button
                Button(action: viewModel.createAccount) {
                    HStack {
                        Text(String(localized: "button.continue"))
                    }
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.primaryColor)
                    .clipShape(Capsule())
                    .shadow(color: Color.primaryColor.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                
                // Sign In Link
                HStack {
                    Text(String(localized: "Already have an account?"))
                        .foregroundColor(.textSecondary)
                    Button(action: { dismiss() }) {
                        Text(String(localized: "Sign In"))
                            .fontWeight(.bold)
                            .foregroundColor(.primaryColor)
                    }
                }
                .font(.system(size: 16))
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .loadingOverlay(isShowing: viewModel.isLoading, title: String(localized: "signup.loading.creating"))
        .alert(item: $viewModel.alert) { alertType in
            Alert(
                title: Text(alertType.title),
                message: Text(alertType.message),
                dismissButton: .cancel(Text(String(localized: "button.ok")))
            )
        }
        .onChange(of: viewModel.signUpSuccess) { _, success in
            if success {
                onSignUpSuccess()
            }
        }
        .navigationDestination(isPresented: $viewModel.shouldNavigateToProfileSetup) {
            if let userId = viewModel.state.socialUserId {
                ProfileSetupView(userId: userId, email: viewModel.email, onSetupSuccess: onSignUpSuccess)
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}

#Preview {
    SignUpView(onSignUpSuccess: {})
}
