import SwiftUI

struct AudioPlayerView: View {
    @StateObject private var viewModel: AudioPlayerViewModel

    var body: some View {
        NavigationStack {
            switch viewModel.viewState {
            case .initial, .loading:
                ZStack {
                    Color.slateNavy.ignoresSafeArea()
                    ProgressView("Loading...")
                        .tint(.gray)
                        .foregroundColor(.lightGray)
                }

            case .success:
                ZStack {
                    Color.slateNavy.ignoresSafeArea()
                    VStack(spacing: 16) {
                        ImageBlockView(url: URL(string: viewModel.episodeImageUrl))

                        Text(viewModel.titleText)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)

                        Text(viewModel.bodyText)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.lightGray)

                        Text(viewModel.contentPublicStart.formatUnixTimestamp())
                            .font(.caption)
                            .foregroundColor(.gray)

                        TimeSliderView(
                            currentTime: $viewModel.currentTime,
                            duration: viewModel.duration,
                            onEditingChanged: viewModel.onSeekSliderEditingChanged
                        )

                        PlaybackControlsView(
                            isPlaying: viewModel.playerState == .playing,
                            onTap: {
                                viewModel.playPause()
                            }
                        )
                    }
                    .padding()
                }

            case .failure(let error):
                Text("Proovi hiljem uuesti.")
            }
        }
        .task(id: "load-audio-data") {
            await viewModel.loadData()
        }
    }

    init(viewModel: AudioPlayerViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
