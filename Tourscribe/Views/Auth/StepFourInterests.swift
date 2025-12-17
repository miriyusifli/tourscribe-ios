import SwiftUI

struct StepFourInterests: View {
    @Binding var selectedInterests: Set<String>
    let interests: [(String, String, String)]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Tap to collect badges that match your travel style!")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            Text("\(selectedInterests.count)/10 collected")
                .font(.caption)
                .foregroundColor(.primaryColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.primaryColor.opacity(0.1))
                .cornerRadius(20)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(interests, id: \.1) { emoji, name, subtitle in
                        InterestBadge(
                            emoji: emoji,
                            name: name,
                            subtitle: subtitle,
                            isSelected: selectedInterests.contains(name)
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                if selectedInterests.contains(name) {
                                    selectedInterests.remove(name)
                                } else {
                                    selectedInterests.insert(name)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct InterestBadge: View {
    let emoji: String
    let name: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            isPressed = true
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            VStack(spacing: 8) {
                Text(emoji)
                    .font(.system(size: 40))
                    .scaleEffect(isSelected ? 1.2 : 1.0)
                    .rotationEffect(.degrees(isPressed ? 10 : 0))
                
                Text(name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isSelected ? .white : .textPrimary)
                
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.primaryColor : Color.white)
                    .shadow(color: isSelected ? Color.primaryColor.opacity(0.4) : Color.black.opacity(0.05), radius: isSelected ? 12 : 4, x: 0, y: isSelected ? 6 : 2)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
