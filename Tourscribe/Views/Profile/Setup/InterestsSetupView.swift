import SwiftUI

struct InterestsSetupView: View {
    @Bindable var viewModel: ProfileSetupViewModel
    var onSetupSuccess: () -> Void
    
    var body: some View {
        VStack(spacing: StyleGuide.Spacing.xlarge) {
            header
            content
            Spacer()
            footer
        }
        .padding(.horizontal, StyleGuide.Padding.xlarge)
        .padding(.bottom, StyleGuide.Padding.xlarge)
        .padding(.top, StyleGuide.Padding.standard) // Reduced top padding
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

    @ViewBuilder
    private var header: some View {
        VStack(alignment: .leading, spacing: StyleGuide.Spacing.standard) {
            Text(String(localized: "profile.setup.interests.title"))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
            
            // Progress Bar (Step 2 of 2)
            SetupProgressBar(totalSteps: 2, currentStep: 2)
        }
    }

    @ViewBuilder
    private var content: some View {
        StepInterests(
            selectedInterests: $viewModel.selectedInterests,
            interests: viewModel.interests
        )
    }

    @ViewBuilder
    private var footer: some View {
        PrimaryActionButton(
            title: String(localized: "button.complete"),
            isLoading: viewModel.isLoading,
            action: viewModel.completeSetup
        )
    }
}
