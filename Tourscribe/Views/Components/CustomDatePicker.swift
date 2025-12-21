import SwiftUI

struct CustomDatePicker: View {
    let title: String
    @Binding var selection: Date
    var displayedComponents: DatePickerComponents = [.date]

    var body: some View {
        HStack {
            DatePicker(title, selection: $selection, displayedComponents: displayedComponents)
                .datePickerStyle(.compact)
                .tint(.primaryColor)
        }
        .padding(.horizontal, StyleGuide.Padding.medium)
        .padding(.vertical, StyleGuide.Padding.standard)
        .background(.white)
        .cornerRadius(StyleGuide.CornerRadius.standard)
    }
}