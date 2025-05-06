import SwiftUI
import NukeUI
import Nuke

struct ContentItemView: View {
    @StateObject private var viewModel: ContentItemViewModel

    var body: some View {
        VStack(alignment: .center) {
            if let url = viewModel.itemImage {
                LazyImage(
                    url: url
                ) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        Color.gray.opacity(0.3)
                    }
                }
                .frame(width: 100, height: 100)
                .clipped()
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.35), radius: 12, x: 0, y: 6)
            } else {
                Color.gray.opacity(0.3)
                    .frame(width: 100, height: 100)
                    .cornerRadius(12)
            }

            Text(viewModel.title)
                .font(.caption)
                .multilineTextAlignment(.center)
                .lineLimit(3)
                .truncationMode(.tail)
                .frame(width: 100)
                .foregroundColor(.white)
        }
    }

    init(viewModel: ContentItemViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}
