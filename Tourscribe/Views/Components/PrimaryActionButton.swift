import SwiftUI

struct PrimaryActionButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void
    
    init(title: String, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView().tint(.white)
                } else {
                    Text(title)
                }
            }
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.primaryColor)
            .clipShape(Capsule())
            .shadow(color: Color.primaryColor.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .disabled(isLoading)
    }
}
