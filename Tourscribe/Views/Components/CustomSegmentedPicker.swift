import SwiftUI

struct CustomSegmentedPicker: UIViewRepresentable {
    @Binding var selection: Int
    let items: [String]
    
    func makeUIView(context: Context) -> UISegmentedControl {
        let control = TallSegmentedControl(items: items)
        control.selectedSegmentIndex = selection
        control.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged(_:)), for: .valueChanged)
        
        // Styling
        control.selectedSegmentTintColor = UIColor(Color.primaryColor)
        control.backgroundColor = UIColor(Color.black.opacity(0.05))
        
        let descriptor = UIFont.systemFont(ofSize: 16, weight: .medium).fontDescriptor.withDesign(.rounded)
        let font = UIFont(descriptor: descriptor ?? UIFont.systemFont(ofSize: 16).fontDescriptor, size: 16)
        
        control.setTitleTextAttributes([
            .foregroundColor: UIColor.white,
            .font: font
        ], for: .selected)
        
        control.setTitleTextAttributes([
            .foregroundColor: UIColor(Color.textPrimary),
            .font: font
        ], for: .normal)
        
        return control
    }
    
    func updateUIView(_ uiView: UISegmentedControl, context: Context) {
        uiView.selectedSegmentIndex = selection
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: CustomSegmentedPicker
        
        init(_ parent: CustomSegmentedPicker) {
            self.parent = parent
        }
        
        @objc func valueChanged(_ sender: UISegmentedControl) {
            parent.selection = sender.selectedSegmentIndex
        }
    }
    
    private class TallSegmentedControl: UISegmentedControl {
        override var intrinsicContentSize: CGSize {
            // Enforce a taller height
            return CGSize(width: super.intrinsicContentSize.width, height: 42)
        }
    }
}
