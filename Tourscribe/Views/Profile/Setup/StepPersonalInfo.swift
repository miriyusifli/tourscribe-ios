import SwiftUI

struct StepPersonalInfo: View {
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var birthDate: Date
    @Binding var gender: String
    
    let genders = Gender.allCases
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                CustomTextField(placeholder: String(localized: "placeholder.first_name"), text: $firstName)
                CustomTextField(placeholder: String(localized: "placeholder.last_name"), text: $lastName)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                CustomDatePicker(
                    title: String(localized: "label.date_of_birth"),
                    selection: $birthDate,
                    displayedComponents: .date
                )
            }
            
            VStack(alignment: .leading, spacing: 10) {
            
                HStack(spacing: 12) {
                    ForEach(genders) { option in
                        Button(action: { gender = option.rawValue }) {
                            Text(option.localizedName)
                                .font(.system(size: 16))
                                .foregroundColor(gender == option.rawValue ? .white : .textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(gender == option.rawValue ? Color.primaryColor : Color.white)
                                .cornerRadius(12)
                        }
                    }
                }
            }
        }
    }
}
