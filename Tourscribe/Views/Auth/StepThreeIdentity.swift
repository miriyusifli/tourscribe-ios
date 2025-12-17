import SwiftUI

struct StepThreeIdentity: View {
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var birthDate: Date
    @Binding var gender: String
    
    let genders = ["Male", "Female", "Other"]
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                CustomTextField(placeholder: "First Name", text: $firstName)
                CustomTextField(placeholder: "Last Name", text: $lastName)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    DatePicker("Date of Birth", selection: $birthDate, in: ...Date(), displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .tint(.primaryColor)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(.white)
                .cornerRadius(12)
            }
            
            VStack(alignment: .leading, spacing: 10) {
            
                HStack(spacing: 12) {
                    ForEach(genders, id: \.self) { option in
                        Button(action: { gender = option }) {
                            Text(option)
                                .font(.system(size: 16))
                                .foregroundColor(gender == option ? .white : .textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(gender == option ? Color.primaryColor : Color.white)
                                .cornerRadius(12)
                        }
                    }
                }
            }
        }
    }
}
