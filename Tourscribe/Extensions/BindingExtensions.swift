import SwiftUI

extension Binding where Value: Equatable {
    init(_ source: Binding<Value?>, replacingNilWith nilValue: Value) {
        self.init(
            get: { source.wrappedValue ?? nilValue },
            set: { newValue in
                source.wrappedValue = (newValue == nilValue) ? nil : newValue
            }
        )
    }
}
