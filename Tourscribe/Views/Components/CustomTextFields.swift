import SwiftUI

struct CustomTextField: View {
    var icon: String? = nil
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(.primaryColor)
                    .font(.system(size: 18))
                    .frame(width: 24)
            }
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.gray))
                .foregroundColor(.textPrimary)
                .font(.system(size: 16))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.white)
        .cornerRadius(12)
    }
}

struct CustomSecureField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.primaryColor)
                .font(.system(size: 18))
                .frame(width: 24)
            SecureField("", text: $text, prompt: Text(placeholder).foregroundColor(.gray))
                .foregroundColor(.black)
                .font(.system(size: 16))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.white)
        .cornerRadius(12)
    }
}
