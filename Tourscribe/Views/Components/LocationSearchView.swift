import SwiftUI
import MapKit

struct LocationSearchView: View {
    @StateObject private var viewModel: LocationSearchViewModel
    @Binding var location: Location?
    @Environment(\.dismiss) private var dismiss
    
    init(location: Binding<Location?>, filter: MKPointOfInterestFilter? = nil) {
        self._location = location
        self._viewModel = StateObject(wrappedValue: LocationSearchViewModel(filter: filter))
    }

    var body: some View {
        AppView {
            ZStack {
                VStack {
                    searchBar
                    completionsList
                }
                
                if viewModel.isSearching {
                    searchingOverlay
                }
            }
        }
        .navigationTitle(String(localized: "location.search.title"))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField(String(localized: "location.search.placeholder"), text: Binding(
                get: { viewModel.searchQuery },
                set: { viewModel.setSearchQuery($0) }
            ))
            .foregroundColor(.primary)
            Button(action: { viewModel.clearSearch() }) {
                Image(systemName: "xmark.circle.fill")
                    .opacity(viewModel.searchQuery.isEmpty ? 0 : 1)
            }
        }
        .padding(StyleGuide.Padding.medium)
        .background(Color.white)
        .cornerRadius(StyleGuide.CornerRadius.standard)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private var completionsList: some View {
        List(viewModel.completions) { completion in
            VStack(alignment: .leading) {
                Text(completion.title)
                    .font(.headline)
                Text(completion.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                Task {
                    if let selected = await viewModel.selectCompletion(completion) {
                        location = selected
                        dismiss()
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
    }
    
    @ViewBuilder
    private var searchingOverlay: some View {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
        ProgressView(String(localized: "location.search.searching"))
            .progressViewStyle(CircularProgressViewStyle())
            .padding()
            .background(Color.white)
            .cornerRadius(StyleGuide.CornerRadius.standard)
    }
}

extension MKLocalSearchCompletion: Identifiable {
    public var id: String {
        "\(title)\(subtitle)"
    }
}

#Preview {
    NavigationStack {
        LocationSearchView(location: .constant(nil))
    }
}
