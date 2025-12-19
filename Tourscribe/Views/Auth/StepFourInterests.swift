import SwiftUI

import SwiftUI

struct StepFourInterests: View {
    @Binding var selectedInterests: Set<String>
    let interests: [Interest]
    
    // Grid configuration
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            headerView
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(interests, id: \.id) { interest in
                        InterestBadge(
                            emoji: interest.emoji,
                            name: interest.name,
                            subtitle: interest.description,
                            isSelected: selectedInterests.contains(interest.id),
                            action: { toggleInterest(interest.id) }
                        )
                    }
                }
                .padding(.bottom, 20) // Add padding for scrolling
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        VStack(spacing: 20) {
            Text(String(localized: "signup.interests.subtitle"))
                .font(.subheadline)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 12) {
                countBadge
                hintText
            }
        }
    }
    
    private var countBadge: some View {
        Text("\(selectedInterests.count)/10")
            .font(.caption)
            .foregroundColor(.primaryColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.primaryColor.opacity(0.1))
            .cornerRadius(20)
    }
    
    private var hintText: some View {
        let (text, color) = selectionHint
        return Text(text)
            .font(.caption)
            .foregroundColor(color)
    }
    
    // MARK: - Logic
    
    private func toggleInterest(_ id: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            if selectedInterests.contains(id) {
                selectedInterests.remove(id)
            } else {
                selectedInterests.insert(id)
            }
        }
    }
    
    private var selectionHint: (String, Color) {
        let count = selectedInterests.count
        if count == 0 {
            return (String(localized: "signup.interests.hint.empty"), .textSecondary)
        } else if count < 3 {
            let remaining = 3 - count
            let format = String(localized: "signup.interests.hint.remaining")
            return (String(format: format, remaining), .orange)
        } else {
            return (String(localized: "signup.interests.hint.complete"), .green)
        }
    }
}
