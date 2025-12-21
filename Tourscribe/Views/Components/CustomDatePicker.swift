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
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.white)
        .cornerRadius(12)
    }
}