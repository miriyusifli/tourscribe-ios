import SwiftUI
import ImageIO

struct GifImage: UIViewRepresentable {
    private let name: String

    init(_ name: String) {
        self.name = name
    }

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        // Ensure it respects the frame set in SwiftUI
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        imageView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)
        
        if let url = Bundle.main.url(forResource: name, withExtension: "gif"),
           let data = try? Data(contentsOf: url) {
            imageView.image = UIImage.gif(data: data)
        }
        
        return imageView
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        // No dynamic updates needed for this use case
    }
}

// MARK: - UIImage Extension for GIF Support
extension UIImage {
    static func gif(data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        
        var images = [UIImage]()
        let count = CGImageSourceGetCount(source)
        var duration: TimeInterval = 0
        
        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: cgImage))
                
                // Get frame duration
                var frameDuration: TimeInterval = 0.1 // default
                if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any],
                   let gifInfo = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any] {
                    
                    if let delayTime = gifInfo[kCGImagePropertyGIFUnclampedDelayTime as String] as? TimeInterval {
                        frameDuration = delayTime
                    } else if let delayTime = gifInfo[kCGImagePropertyGIFDelayTime as String] as? TimeInterval {
                        frameDuration = delayTime
                    }
                }
                
                // If frame duration is extremely small, assume 0.1s
                if frameDuration < 0.011 {
                    frameDuration = 0.1
                }
                
                duration += frameDuration
            }
        }
        
        return UIImage.animatedImage(with: images, duration: duration)
    }
}

#Preview {
    GifImage("loading")
        .frame(width: 100, height: 100)
}
