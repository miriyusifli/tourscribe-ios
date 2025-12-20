import SwiftUI

struct SetupProgressBar: View {
    let totalSteps: Int
    let currentStep: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step <= currentStep ? Color.primaryColor : Color.gray.opacity(0.3))
                    .frame(height: 6)
            }
        }
    }
}
