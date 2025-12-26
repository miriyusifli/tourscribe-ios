import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: UpdateProfileViewModel
    
    init(user: UserProfile, onUpdate: @escaping (UserProfile) -> Void) {
        let vm = UpdateProfileViewModel(user: user)
        vm.onUpdate = { profile in
            onUpdate(profile)
        }
        _viewModel = StateObject(wrappedValue: vm)
    }
    
    var body: some View {
        AppView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: StyleGuide.Spacing.xlarge) {
                    StepPersonalInfo(
                        firstName: $viewModel.firstName,
                        lastName: $viewModel.lastName,
                        birthDate: $viewModel.birthDate,
                        gender: $viewModel.gender
                    )
                    
                    PrimaryActionButton(
                        title: String(localized: "button.save"),
                        isLoading: viewModel.isLoading
                    ) {
                        viewModel.update()
                    }
                }
                .padding(.horizontal)
                .padding(.top, StyleGuide.Padding.xlarge)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(String(localized: "profile.edit.title"))
                    .font(.headline)
                    .foregroundColor(.textPrimary)
            }
        }
        .alert(item: $viewModel.alert) { alertType in
            Alert(
                title: Text(alertType.title),
                message: Text(alertType.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .onChange(of: viewModel.isLoading) { oldValue, newValue in
            if oldValue && !newValue && viewModel.alert == nil {
                dismiss()
            }
        }
    }
}

#Preview {
    EditProfileView(
        user: UserProfile(
            id: UUID().uuidString,
            email: "test@example.com",
            firstName: "Test",
            lastName: "User",
            birthDate: Date(),
            gender: "Male",
            interests: [],
            createdAt: Date(),
            updatedAt: Date()
        ),
        onUpdate: { _ in }
    )
}
