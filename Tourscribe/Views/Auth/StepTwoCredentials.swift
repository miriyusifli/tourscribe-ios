import SwiftUI

struct StepTwoCredentials: View {
    @Binding var email: String
    @Binding var password: String
    var isEmailValid: Bool
    
    private var passwordStrength: (String, Color) {
        let length = password.count
        let hasUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasNumber = password.range(of: "[0-9]", options: .regularExpression) != nil
        let hasSpecial = password.range(of: "[^A-Za-z0-9]", options: .regularExpression) != nil
        
        if length == 0 { return ("", .clear) }
        if length < 6 { return ("Weak", .red) }
        if length >= 8 && hasUppercase && hasNumber { return ("Strong", .green) }
        if length >= 6 && (hasUppercase || hasNumber || hasSpecial) { return ("Medium", .orange) }
        return ("Weak", .red)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                CustomTextField(icon: "envelope.fill", placeholder: "Email address", text: $email)
                
                if !email.isEmpty && !isEmailValid {
                    Text(String(localized: "validation.email.invalid.generic"))
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.leading, 4)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                CustomSecureField(icon: "lock.fill", placeholder: "Create password", text: $password)
                
                if !password.isEmpty {
                    HStack(spacing: 6) {
                        Text(passwordStrength.0)
                            .font(.caption)
                            .foregroundColor(passwordStrength.1)
                        
                        HStack(spacing: 4) {
                            ForEach(0..<3) { index in
                                Capsule()
                                    .fill(index < strengthLevel ? passwordStrength.1 : Color.white.opacity(0.2))
                                    .frame(width: 30, height: 4)
                            }
                        }
                    }
                    .padding(.leading, 4)
                }
            }
            
            Text(String(localized: "label.verification.sent"))
                .font(.caption)
                .foregroundColor(.textSecondary)
                .padding(.leading, 4)
        }
    }
    
    private var strengthLevel: Int {
        switch passwordStrength.0 {
        case "Weak": return 1
        case "Medium": return 2
        case "Strong": return 3
        default: return 0
        }
    }
}
