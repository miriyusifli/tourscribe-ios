import SwiftUI

@MainActor
struct SignUpView: View {
    @State private var viewModel = SignUpViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        @Bindable var viewModel = viewModel
        
        AppView {
            VStack(spacing: StyleGuide.Spacing.xlarge) {
                header
                form
                
                Spacer()
                
                footerButton
                signInLink
            }
            .padding(.horizontal, StyleGuide.Padding.xlarge)
            .padding(.top, StyleGuide.Padding.small)
            .padding(.bottom, StyleGuide.Padding.xlarge)
        }
        .loadingOverlay(isShowing: viewModel.isLoading, title: String(localized: "signup.loading.creating"))
        .alert(item: $viewModel.alert) { alertType in
            Alert(
                title: Text(alertType.title),
                message: Text(alertType.message),
                dismissButton: .cancel(Text(String(localized: "button.ok")))
            )
        }
    }

    @ViewBuilder
    private var header: some View {
        Text(String(localized: "signup.credentials.title"))
            .font(.system(size: 34, weight: .bold, design: .rounded))
            .foregroundColor(.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var form: some View {
        VStack(alignment: .leading, spacing: StyleGuide.Spacing.xlarge) {
            VStack(alignment: .leading, spacing: StyleGuide.Spacing.medium) {
                CustomTextField(icon: "envelope.fill", placeholder: String(localized: "label.email"), text: $viewModel.email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled(true)
                
                if !viewModel.email.isEmpty && !viewModel.isEmailValid {
                    Text(String(localized: "validation.email.invalid.generic"))
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.leading, StyleGuide.Spacing.small)
                }
            }
            
            VStack(alignment: .leading, spacing: StyleGuide.Spacing.medium) {
                CustomSecureField(icon: "lock.fill", placeholder: String(localized: "label.password"), text: $viewModel.password)
                
                if !viewModel.password.isEmpty {
                    HStack(spacing: StyleGuide.Spacing.medium) {
                        Text(LocalizedStringKey(viewModel.passwordStrength.label))
                            .font(.caption)
                            .foregroundColor(viewModel.passwordStrength.color)
                        
                        HStack(spacing: StyleGuide.Spacing.small) {
                            ForEach(0..<3) { index in
                                Capsule()
                                    .fill(index < viewModel.passwordStrength.level ? viewModel.passwordStrength.color : Color.white.opacity(0.2))
                                    .frame(width: 30, height: 4)
                            }
                        }
                    }
                    .padding(.leading, StyleGuide.Spacing.small)
                }
            }
        }
    }

    @ViewBuilder
    private var footerButton: some View {
        Button(action: viewModel.createAccount) {
            HStack {
                Text(String(localized: "button.continue"))
            }
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, StyleGuide.Padding.medium)
            .background(Color.primaryColor)
            .clipShape(Capsule())
            .shadow(color: Color.primaryColor.opacity(0.3), radius: 10, x: 0, y: 5)
        }
    }

    @ViewBuilder
    private var signInLink: some View {
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
}

#Preview {
    SignUpView()
}
