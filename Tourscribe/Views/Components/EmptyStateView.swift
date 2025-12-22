import SwiftUI

struct EmptyStateView: View {
    let imageName: String
    let message: String

    var body: some View {
        VStack(spacing: StyleGuide.Spacing.standard) {
            Image(systemName: imageName)
                .font(.system(size: StyleGuide.IconSize.large))
                .foregroundColor(.textSecondary)
            Text(message)
                .font(.headline)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .padding(.top, StyleGuide.Padding.huge)
    }
}
