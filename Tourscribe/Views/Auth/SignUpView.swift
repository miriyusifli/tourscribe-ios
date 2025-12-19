import SwiftUI

// MARK: - Main Sign-Up View
@MainActor
struct SignUpView: View {
    @State private var viewModel = SignUpViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background Gradient
                LinearGradient(
                    colors: [.backgroundTop, .backgroundBottom],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    SignUpHeaderView(
                        currentStep: viewModel.currentStep,
                        title: viewModel.titleForStep(viewModel.currentStep),
                        onBack: viewModel.previousStep
                    )
                    
                    SignUpContentView(viewModel: viewModel)
                    
                    Spacer()
                    
                    SignUpFooterView(
                        currentStep: viewModel.currentStep,
                        action: viewModel.nextStep
                    )
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 24)
                
                if viewModel.isLoading {
                    LoadingOverlay(message: viewModel.currentStep == 1 ? "Creating your account..." : "Updating profile...")
                }
            }
            .gesture(
                DragGesture()
                    .onEnded { gesture in
                        if gesture.translation.width > 100 && viewModel.currentStep > 0 {
                            viewModel.previousStep()
                        }
                    }
            )
            .alert(item: $viewModel.alert) { alertType in
                Alert(
                    title: Text(alertType.title),
                    message: Text(alertType.message),
                    dismissButton: .cancel(Text(String(localized: "button.ok")))
                )
            }
            .fullScreenCover(isPresented: $viewModel.signUpSuccess) {
                MyTrips()
            }
        }
    }
}

// MARK: - Subviews

struct SignUpHeaderView: View {
    let currentStep: Int
    let title: String
    let onBack: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if currentStep > 0 {
                    Button(action: onBack) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text(String(localized: "button.back"))
                                .font(.system(size: 17))
                        }
                        .foregroundColor(.textPrimary)
                    }
                }
                Spacer()
            }
            .padding(.bottom, 8)
            
            Text(title)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.textPrimary)
            
            // Progress Bar
            if currentStep > 0 {
                HStack(spacing: 8) {
                    ForEach(1...3, id: \.self) { step in
                        Capsule()
                            .fill(step <= currentStep ? Color.primaryColor : Color.white.opacity(0.1))
                            .frame(height: 6)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: currentStep)
            }
        }
    }
}

struct SignUpContentView: View {
    @Bindable var viewModel: SignUpViewModel
    
    var body: some View {
        ZStack {
            switch viewModel.currentStep {
            case 0:
                StepOneGate(viewModel: viewModel)
            case 1:
                StepTwoCredentials(
                    email: $viewModel.email,
                    password: $viewModel.password,
                    isEmailValid: viewModel.isEmailValid
                )
            case 2:
                StepThreeIdentity(
                    firstName: $viewModel.firstName,
                    lastName: $viewModel.lastName,
                    birthDate: $viewModel.birthDate,
                    gender: $viewModel.gender
                )
            case 3:
                StepFourInterests(
                    selectedInterests: $viewModel.selectedInterests,
                    interests: viewModel.interests
                )
            default:
                EmptyView()
            }
        }
    }
}

struct SignUpFooterView: View {
    let currentStep: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(currentStep == 3 ? String(localized: "button.begin.journey") : String(localized: "button.continue"))
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

struct LoadingOverlay: View {
    let message: String
    
    var body: some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
        
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(32)
        .background(Color.black.opacity(0.7))
        .cornerRadius(16)
    }
}

#Preview {
    SignUpView()
}
