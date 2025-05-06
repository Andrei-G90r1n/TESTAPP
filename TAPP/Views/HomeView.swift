import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @State private var isPlayerPresented = false

    var body: some View {
        NavigationStack {
            switch viewModel.viewState {
            case .initial, .loading:
                ZStack {
                    Color.deepBlue.ignoresSafeArea()
                    ProgressView("Loading...")
                        .tint(.gray)
                        .foregroundColor(.lightGray)
                }
            case .success:
                ZStack {
                    Color.deepBlue.ignoresSafeArea()
                    List {
                        ForEach(viewModel.sections, id: \.header) { contentSection in
                            Section(
                                header: Text(contentSection.header)
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                            ) {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    LazyHStack(alignment: .top, spacing: 16) {
                                        ForEach(contentSection.data, id: \.id) { contentItem in
                                            ContentItemView(
                                                viewModel: ContentItemViewModel(contentItem: contentItem)
                                            )
                                            .onTapGesture {
                                                viewModel.select(item: contentItem)
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .listRowBackground(Color.clear)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .sheet(item: $viewModel.selectedItem, content: { item in
                        AudioPlayerView(viewModel: AudioPlayerViewModel(contentItem: item))
                    })
                }
            case .failure(let error):
                Text("Failed to load home data: \(error)")
            }
        }
        .task(id: "load-home-data") {
            await viewModel.loadData()
        }
    }

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}
