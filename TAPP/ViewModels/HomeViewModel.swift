import Foundation
import Combine

class HomeViewModel: ObservableObject {
    enum ViewState: Equatable {
        case initial
        case loading
        case success
        case failure(String)
    }

    @Published var viewState: ViewState = .initial
    @Published var selectedItem: ContentItemModel?
    @Published var sections: [ContentSectionModel] = []

    private let apiService: APIService

    init(apiService: APIService = .shared) {
        self.apiService = apiService
    }

    func select(item: ContentItemModel) {
        selectedItem = item
    }

    @MainActor
    func loadData() async {
        viewState = .loading
        do {
            let sectionsData = try await apiService.getHomeData()
            sections = sectionsData
            viewState = .success
        } catch {
            viewState = .failure(error.localizedDescription)
        }
    }
}
