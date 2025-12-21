import SwiftUI

struct CustomTextField: View {
    var icon: String? = nil
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: StyleGuide.Spacing.standard) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(.primaryColor)
                    .font(.system(size: 18))
                    .frame(width: StyleGuide.Padding.large)
            }
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.gray))
                .padding(.horizontal, StyleGuide.Padding.medium)
                .padding(.vertical, StyleGuide.Padding.medium)
                .background(.white)
                .cornerRadius(StyleGuide.CornerRadius.standard)
        }
    }
}

struct CustomSecureField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: StyleGuide.Spacing.standard) {
            Image(systemName: icon)
                .foregroundColor(.primaryColor)
                .font(.system(size: 18))
                .frame(width: StyleGuide.Padding.large)
            SecureField("", text: $text, prompt: Text(placeholder).foregroundColor(.gray))
                .foregroundColor(.black)
                .font(.system(size: 16))
        }
        .padding(.horizontal, StyleGuide.Padding.medium)
        .padding(.vertical, StyleGuide.Padding.medium)
        .background(.white)
        .cornerRadius(StyleGuide.CornerRadius.standard)
    }
}
