import SwiftUI

struct TripListAddButton: View {
    @ObservedObject var viewModel: MyTripsViewModel
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                viewModel.isShowingCreateTrip = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: StyleGuide.IconSize.standard, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: StyleGuide.IconSize.xlarge, height: StyleGuide.IconSize.xlarge)
                    .background(Color.primaryColor)
                    .clipShape(Circle())
            }
            .padding(.trailing, StyleGuide.Padding.large)
            .padding(.bottom, StyleGuide.Padding.large)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}
