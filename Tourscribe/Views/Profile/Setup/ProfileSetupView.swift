import SwiftUI

struct ProfileSetupView: View {
    @State private var viewModel: ProfileSetupViewModel
    var onSetupSuccess: (UserProfile) -> Void
    
    init(userId: String, email: String, onSetupSuccess: @escaping (UserProfile) -> Void) {
        self._viewModel = State(initialValue: ProfileSetupViewModel(userId: userId, email: email))
        self.onSetupSuccess = onSetupSuccess
    }
    
    var body: some View {
        VStack(spacing: StyleGuide.Padding.large) {
            header
            content
            Spacer()
            footer
        }
        .padding(StyleGuide.Padding.large)
        .background(Color.background)
        .alert(item: $viewModel.alert) { alertType in
            Alert(
                title: Text(alertType.title),
                message: Text(alertType.message),
                dismissButton: .cancel(Text("OK"))
            )
        }
        .navigationDestination(isPresented: $viewModel.navigateToInterests) {
            InterestsSetupView(viewModel: viewModel, onSetupSuccess: onSetupSuccess)
        }
    }

    @ViewBuilder
    private var header: some View {
        VStack(alignment: .leading, spacing: StyleGuide.Spacing.standard) {
            Text(String(localized: "profile.setup.identity.title"))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
            
            SetupProgressBar(totalSteps: 2, currentStep: 1)
        }
        .padding(.top, StyleGuide.Padding.large)
    }

    @ViewBuilder
    private var content: some View {
        StepPersonalInfo(
            firstName: $viewModel.firstName,
            lastName: $viewModel.lastName,
            birthDate: $viewModel.birthDate,
            gender: $viewModel.gender
        )
    }

    @ViewBuilder
    private var footer: some View {
        PrimaryActionButton(
            title: String(localized: "button.continue"),
            action: viewModel.continueToInterests
        )
    }
}