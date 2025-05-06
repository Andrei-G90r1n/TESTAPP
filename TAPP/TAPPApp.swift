import SwiftUI

@main
struct TAPPApp: App {
    var body: some Scene {
        WindowGroup {
            ZStack {
                Color.slateNavy.ignoresSafeArea()
                HomeView(viewModel: HomeViewModel())
            }.task {
                await MainActor.run {
                    restorePlayback()
                }
            }
        }
    }

    private func restorePlayback() {
        if let state = PlaybackStateManager.load(), let stateStreamUrl = state.streamUrl {
            let service = AudioPlayerService.shared
            service.load(url: stateStreamUrl, metadata: state.metadata)
            service.seek(to: state.position)
        }
    }
}
