import UIKit
import ImageIO

extension UIImage {
    static func gif(data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        
        var images = [UIImage]()
        let count = CGImageSourceGetCount(source)
        var duration: TimeInterval = 0
        
        for i in 0..<count {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: cgImage))
                
                var frameDuration: TimeInterval = 0.1
                if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any],
                   let gifInfo = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any] {
                    if let delayTime = gifInfo[kCGImagePropertyGIFUnclampedDelayTime as String] as? TimeInterval {
                        frameDuration = delayTime
                    } else if let delayTime = gifInfo[kCGImagePropertyGIFDelayTime as String] as? TimeInterval {
                        frameDuration = delayTime
                    }
                }
                
                if frameDuration < 0.011 {
                    frameDuration = 0.1
                }
                duration += frameDuration
            }
        }
        
        return UIImage.animatedImage(with: images, duration: duration)
    }
}
