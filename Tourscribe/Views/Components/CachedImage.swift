import SwiftUI
import Kingfisher

struct CachedImage: View {
    let url: URL
    let size: CGSize
    var contentMode: SwiftUI.ContentMode = .fill
    
    var body: some View {
        KFImage(url)
            .placeholder { ProgressView() }
            .downsampling(size: size)
            .scaleFactor(UIScreen.main.scale)
            .fade(duration: 0.25)
            .resizable()
            .aspectRatio(contentMode: contentMode)
    }
}
