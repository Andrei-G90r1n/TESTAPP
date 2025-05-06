import SwiftUI

class ContentItemViewModel: ObservableObject {
    let contentItem: ContentItemModel

    var title: String {
        contentItem.heading
    }

    var itemImage: URL? {
        guard let urlString = contentItem.photos.first?.photoUrlBase else {
            return nil
        }
        return URL(string: urlString)
    }

    var itemImageUrlString: String? {
        return contentItem.photos.first?.photoUrlBase ?? nil
    }

    init(contentItem: ContentItemModel) {
        self.contentItem = contentItem
    }
}
