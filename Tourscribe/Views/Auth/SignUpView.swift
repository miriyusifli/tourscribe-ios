import SwiftUI

// MARK: - Main Sign-Up View
struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: [.backgroundTop, .backgroundBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 25) {
                // Header & Progress Indicator
                headerSection
                
                // Content Transition
                ZStack {
                    switch viewModel.currentStep {
                    case 0: StepOneGate()
                    case 1: StepTwoCredentials(email: $viewModel.email, password: $viewModel.password, isEmailValid: viewModel.isEmailValid)
                    case 2: StepThreeIdentity(firstName: $viewModel.firstName, lastName: $viewModel.lastName, birthDate: $viewModel.birthDate, gender: $viewModel.gender)
                    case 3: StepFourInterests(selectedInterests: $viewModel.selectedInterests, interests: viewModel.interests)
                    default: EmptyView()
                    }
                }
                
                Spacer()
                
                // Footer Controls
                navigationControls
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.width > 100 && viewModel.currentStep > 0 {
                        viewModel.previousStep()
                    }
                }
        )
    }
    
    // MARK: - Subviews
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if viewModel.currentStep > 0 {
                    Button(action: { viewModel.previousStep() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 17))
                        }
                        .foregroundColor(.textPrimary)
                    }
                }
                Spacer()
            }
            .padding(.bottom, 8)
            
            Text(viewModel.titleForStep(viewModel.currentStep))
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
            
            // Progress Bar - only show for steps 1-3
            Group {
                if viewModel.currentStep > 0 {
                    HStack(spacing: 8) {
                        ForEach(1...3, id: \.self) { step in
                            Capsule()
                                .fill(step <= viewModel.currentStep ? Color.primaryColor : Color.white.opacity(0.1))
                                .frame(height: 6)
                        }
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
        }
    }
    
    private var navigationControls: some View {
        Button(action: viewModel.nextStep) {
            HStack {
                Text(viewModel.currentStep == 3 ? "Begin Journey" : "Continue")
            }
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.primaryColor)
            .clipShape(Capsule())
            .shadow(color: Color.primaryColor.opacity(0.3), radius: 10, x: 0, y: 5)
        }
    }
}

#Preview {
    SignUpView()
}
