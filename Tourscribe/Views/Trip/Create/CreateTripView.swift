import SwiftUI

struct CreateTripView: View {
    @StateObject private var viewModel = CreateTripViewModel()
    @Environment(\.dismiss) private var dismiss
    @Binding var navigationPath: NavigationPath
    @State private var showDates: Bool = false
    
    var body: some View {
        AppView {
            VStack(spacing: 24) {
                // Form Fields
                VStack(alignment: .leading, spacing: 20) {
                    
                    CustomTextField(
                        placeholder: String(localized: "trip.name.placeholder"),
                        text: $viewModel.tripName
                    )
                    
                    Toggle(isOn: $showDates) {
                        Text(String(localized: "label.set_dates"))
                            .font(.body)
                            .foregroundColor(.textPrimary)
                    }
                    .tint(.primaryColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .cornerRadius(12)
                    .onChange(of: showDates) { _, newValue in
                        if newValue {
                            viewModel.startDate = Date()
                            viewModel.endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())
                        } else {
                            viewModel.startDate = nil
                            viewModel.endDate = nil
                        }
                    }
                    
                    if showDates {
                        VStack(spacing: 12) {
                            CustomDatePicker(
                                title: String(localized: "label.start_date"),
                                selection: Binding(
                                    get: { viewModel.startDate ?? Date() },
                                    set: { viewModel.startDate = $0 }
                                ),
                                displayedComponents: [.date]
                            )
                            
                            CustomDatePicker(
                                title: String(localized: "label.end_date"),
                                selection: Binding(
                                    get: { viewModel.endDate ?? Date() },
                                    set: { viewModel.endDate = $0 }
                                ),
                                displayedComponents: [.date]
                            )
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .animation(.spring(), value: showDates)
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                PrimaryActionButton(
                    title: String(localized: "trip.create.button"),
                    isLoading: viewModel.isLoading,
                    action: {
                        Task {
                            await viewModel.createTrip()
                        }
                    }
                )
            }
            .padding(24)
        }
        .navigationTitle(String(localized: "trip.create.title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(String(localized: "button.cancel")) {
                    dismiss()
                }
            }
        }
        .onChange(of: viewModel.createdTrip) { _, trip in
            if trip != nil {
                dismiss()
            }
        }
    }
}


struct CreateTripView_Previews: PreviewProvider {
    static var previews: some View {
        CreateTripView(navigationPath: .constant(NavigationPath()))
    }
}
