import SwiftUI

struct StepInterests: View {
    @Binding var selectedInterests: Set<String>
    let interests: [Interest]
    
    // Grid configuration
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(spacing: StyleGuide.Spacing.xlarge) {
            headerView
            
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: StyleGuide.Spacing.large) {
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
            }
        }
    }
    
    // MARK: - Subviews
    
    private var headerView: some View {
        HStack() {
            hintText
                .frame(maxWidth: .infinity, alignment: .leading)
            
            countBadge
        }
    }
    
    private var countBadge: some View {
        Text("\(selectedInterests.count)/10")
            .font(.caption)
            .foregroundColor(.primaryColor)
            .padding(.horizontal, StyleGuide.Padding.standard)
            .padding(.vertical, StyleGuide.Padding.small)
            .background(Color.primaryColor.opacity(0.1))
            .cornerRadius(StyleGuide.CornerRadius.xlarge)
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
            return (String(localized: "profile.setup.interests.hint.empty"), .textSecondary)
        } else if count < 3 {
            let remaining = 3 - count
            let format = String(localized: "profile.setup.interests.hint.remaining")
            return (String(format: format, remaining), .orange)
        } else {
            return (String(localized: "profile.setup.interests.hint.complete"), .green)
        }
    }
}
