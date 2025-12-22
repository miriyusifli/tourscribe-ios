import SwiftUI

struct RefreshLoadingView: View {
    var body: some View {
        ProgressView()
            .frame(maxWidth: .infinity, alignment: .center)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .padding(.top, StyleGuide.Padding.xxlarge)
    }
}
