import SwiftUI
import NukeUI

struct ImageBlockView: View {
    let url: URL?

    var body: some View {
        if let url = url {
            LazyImage(url: url) { state in
                if let image = state.image {
                    image.resizable().scaledToFill()
                } else {
                    Color.gray.opacity(0.3)
                }
            }
            .frame(width: 200, height: 200)
            .clipped()
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.35), radius: 12, x: 0, y: 6)
        } else {
            Color.gray.opacity(0.3)
                .frame(width: 100, height: 100)
                .cornerRadius(12)
        }
    }
}
