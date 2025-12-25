import SwiftUI

struct ActiveAccommodationBanner: View {
    let name: String
    
    var body: some View {
        Label(name, systemImage: "moon.zzz.fill")
            .font(.caption)
            .lineLimit(1)
            .foregroundStyle(.secondary)
            .padding(.leading, StyleGuide.Padding.small)
    }
}
