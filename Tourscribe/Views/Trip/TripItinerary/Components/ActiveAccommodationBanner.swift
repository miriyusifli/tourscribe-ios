import SwiftUI

struct ActiveAccommodationBanner: View {
    let name: String
    
    var body: some View {
        HStack(spacing: StyleGuide.Spacing.small) {
            Image(systemName: "moon.zzz.fill")
            Text(name)
                .lineLimit(3)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.leading, StyleGuide.Padding.small)
    }
}
