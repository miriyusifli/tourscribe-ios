import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage
    
    private var formattedContent: AttributedString {
        (try? AttributedString(markdown: message.content, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))) ?? AttributedString(message.content)
    }
    
    var body: some View {
        HStack {
            if message.role == .user { Spacer(minLength: StyleGuide.Padding.xxlarge) }
            
            Text(formattedContent)
                .font(.body)
                .padding(StyleGuide.Padding.standard)
                .background(bubbleBackground)
                .foregroundStyle(message.role == .user ? .white : Color.textPrimary)
                .clipShape(RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.large))
                .overlay(
                    RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.large)
                        .stroke(message.role == .assistant ? Color.glassBorder : .clear, lineWidth: StyleGuide.Dimensions.borderWidth)
                )
            
            if message.role == .assistant { Spacer(minLength: StyleGuide.Padding.xxlarge) }
        }
    }
    
    @ViewBuilder
    private var bubbleBackground: some View {
        if message.role == .user {
            Color.primaryColor
        } else {
            Color.lightGray
        }
    }
}
