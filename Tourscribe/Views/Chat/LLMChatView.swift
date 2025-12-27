import SwiftUI

struct LLMChatView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    @State private var isLoading = false
    @State private var remainingRequests: Int?
    
    let tripId: Int64
    let user: UserProfile
    private let chatService = ChatService()
    
    var body: some View {
        NavigationStack {
            AppView {
                VStack(spacing: 0) {
                    messagesList
                    inputBar
                }
            }
            .navigationTitle(String(localized: "chat.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "button.close")) {
                        dismiss()
                    }
                    .foregroundStyle(Color.textPrimary)
                }
                if let remaining = remainingRequests {
                    ToolbarItem(placement: .primaryAction) {
                        Text(String(localized: "chat.remaining_requests \(remaining)"))
                            .font(.caption)
                            .foregroundStyle(Color.textSecondary)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: StyleGuide.Spacing.medium) {
                    if messages.isEmpty {
                        emptyState
                    } else {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    
                    if isLoading {
                        loadingIndicator
                            .id("loading")
                    }
                }
                .padding(StyleGuide.Padding.medium)
            }
            .onChange(of: messages.count) {
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: isLoading) {
                if isLoading {
                    scrollToBottom(proxy: proxy)
                }
            }
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation {
            if isLoading {
                proxy.scrollTo("loading", anchor: .bottom)
            } else if let lastMessage = messages.last {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
    
    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: StyleGuide.Spacing.large) {
            Image(systemName: "sparkles")
                .font(.system(size: 72))
                .foregroundStyle(Color.primaryColor)
            
            VStack(spacing: StyleGuide.Spacing.small) {
                Text(String(localized: "chat.empty.greeting \(user.firstName)"))
                    .font(.title.bold())
                    .foregroundStyle(Color.textPrimary)
                
                Text(String(localized: "chat.empty.subtitle"))
                    .font(.body)
                    .foregroundStyle(Color.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, StyleGuide.Padding.large)
    }
    
    @ViewBuilder
    private var loadingIndicator: some View {
        HStack {
            TypingIndicator()
            Spacer()
        }
    }
    
    @ViewBuilder
    private var inputBar: some View {
        VStack(spacing: StyleGuide.Spacing.medium) {
            HStack(spacing: StyleGuide.Spacing.medium) {
                TextField(String(localized: "chat.placeholder"), text: $messageText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...5)
                    .padding(StyleGuide.Padding.standard)
                    .background(Color.lightGray)
                    .clipShape(RoundedRectangle(cornerRadius: StyleGuide.CornerRadius.xlarge))
                
                Button {
                    Task { await sendMessage() }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: StyleGuide.IconSize.medium))
                        .foregroundStyle(Color.primaryColor)
                        .opacity(messageText.isEmpty || isLoading ? 0.4 : 1.0)
                }
                .disabled(messageText.isEmpty || isLoading)
            }
            
            Text(String(localized: "chat.disclaimer"))
                .font(.caption2)
                .foregroundStyle(Color.textSecondary)
        }
        .padding(StyleGuide.Padding.medium)
    }
    
    private func sendMessage() async {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        let userMessage = ChatMessage(role: .user, content: text)
        messages.append(userMessage)
        messageText = ""
        isLoading = true
        
        defer { isLoading = false }
        
        do {
            let history = messages.map { ChatRequest.ChatMessage(role: $0.role == .user ? "user" : "assistant", content: $0.content) }
            let response = try await chatService.sendMessage(text, history: history, tripId: tripId, user: user)
            remainingRequests = response.remainingRequests
            
            let assistantContent: String
            switch response.type {
            case .text:
                assistantContent = response.content ?? ""
            case .toolCall:
                assistantContent = String(localized: "chat.tool_executed \(response.tool ?? "")")
            }
            
            let assistantMessage = ChatMessage(role: .assistant, content: assistantContent)
            messages.append(assistantMessage)
        } catch {
            let errorMessage = ChatMessage(role: .assistant, content: String(localized: "chat.error"))
            messages.append(errorMessage)
        }
    }
}

#Preview {
    LLMChatView(tripId: 1, user: UserProfile(id: "", email: "", firstName: "", lastName: "", birthDate: Date(), gender: "", interests: [], createdAt: Date(), updatedAt: Date()))
}
