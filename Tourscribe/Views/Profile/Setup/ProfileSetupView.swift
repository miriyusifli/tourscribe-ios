import SwiftUI

struct ProfileSetupView: View {
    @State private var viewModel: ProfileSetupViewModel
    var onSetupSuccess: () -> Void
    
    init(userId: String, email: String, onSetupSuccess: @escaping () -> Void) {
        self._viewModel = State(initialValue: ProfileSetupViewModel(userId: userId, email: email))
        self.onSetupSuccess = onSetupSuccess
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 12) {
                Text(String(localized: "profile.setup.identity.title"))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                
                // Progress Bar (Step 1 of 2)
                SetupProgressBar(totalSteps: 2, currentStep: 1)
            }
            .padding(.top, 24)
            
            // Content: Personal Info Form
            StepPersonalInfo(
                firstName: $viewModel.firstName,
                lastName: $viewModel.lastName,
                birthDate: $viewModel.birthDate,
                gender: $viewModel.gender
            )
            
            Spacer()
            
            // Continue Button
            PrimaryActionButton(
                title: String(localized: "button.continue"),
                action: viewModel.continueToInterests
            )
        }
        .padding(24)
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
}