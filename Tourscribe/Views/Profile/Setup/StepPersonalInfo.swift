import SwiftUI

struct StepPersonalInfo: View {
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var birthDate: Date
    @Binding var gender: String
    
    let genders = Gender.allCases
    
    var body: some View {
        VStack(spacing: StyleGuide.Spacing.xlarge) {
            HStack {
                CustomTextField(placeholder: String(localized: "placeholder.first_name"), text: $firstName)
                CustomTextField(placeholder: String(localized: "placeholder.last_name"), text: $lastName)
            }
            
            VStack(alignment: .leading, spacing: StyleGuide.Spacing.standard) {
                CustomDatePicker(
                    title: String(localized: "label.date_of_birth"),
                    selection: $birthDate,
                    displayedComponents: .date
                )
            }
            
            VStack(alignment: .leading, spacing: StyleGuide.Spacing.standard) {
            
                HStack(spacing: StyleGuide.Spacing.standard) {
                    ForEach(genders) { option in
                        Button(action: { gender = option.rawValue }) {
                            Text(option.localizedName)
                                .font(.system(size: 16))
                                .foregroundColor(gender == option.rawValue ? .white : .textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, StyleGuide.Padding.medium)
                                .background(gender == option.rawValue ? Color.primaryColor : Color.white)
                                .cornerRadius(StyleGuide.CornerRadius.standard)
                        }
                    }
                }
            }
        }
    }
}
