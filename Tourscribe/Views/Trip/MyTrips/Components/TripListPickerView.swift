import SwiftUI

struct TripListPickerView: View {
    @Binding var selectedSegment: TripListSegment

    private var selection: Binding<Int> {
        Binding(
            get: { selectedSegment.rawValue },
            set: { selectedSegment = TripListSegment(rawValue: $0) ?? .upcoming }
        )
    }

    var body: some View {
        CustomSegmentedPicker(
            selection: selection,
            items: TripListSegment.allCases.map { $0.title }
        )
        .frame(height: StyleGuide.Dimensions.standardControlHeight)
        .padding(.horizontal, StyleGuide.Padding.large)
    }
}
