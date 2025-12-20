import SwiftUI

struct InterestsSetupView: View {
    @Bindable var viewModel: ProfileSetupViewModel
    var onSetupSuccess: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(alignment: .leading, spacing: 12) {
                Text(String(localized: "profile.setup.interests.title"))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.textPrimary)
                
                // Progress Bar (Step 2 of 2)
                SetupProgressBar(totalSteps: 2, currentStep: 2)
            }
            
            // Content: Interests Grid
            StepInterests(
                selectedInterests: $viewModel.selectedInterests,
                interests: viewModel.interests
            )
            
            Spacer()
            
            // Complete Button
            PrimaryActionButton(
                title: String(localized: "button.complete"),
                isLoading: viewModel.isLoading,
                action: viewModel.completeSetup
            )
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
        .padding(.top, 10) // Reduced top padding
        .background(Color.background)
        .loadingOverlay(isShowing: viewModel.isLoading, title: String(localized: "profilesetup.loading.saving"))
        .alert(item: $viewModel.alert) { alertType in
            Alert(
                title: Text(alertType.title),
                message: Text(alertType.message),
                dismissButton: .cancel(Text("OK"))
            )
        }
        .onChange(of: viewModel.setupSuccess) { _, success in
            if success {
                onSetupSuccess()
            }
        }
    }
}
