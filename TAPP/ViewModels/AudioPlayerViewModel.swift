import AVFoundation
import Combine
import MediaPlayer
import UIKit

class AudioPlayerViewModel: ObservableObject {
    enum ViewState: Equatable {
        case initial
        case loading
        case success
        case failure(String)
    }

    @Published var viewState: ViewState = .initial
    @Published var playerState: AudioPlayerService.PlayerState = .idle
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published private(set) var currentEpisode: EpisodeModel?

    private let audioService: AudioPlayerService
    private let apiService: APIService
    private let contentItem: ContentItemModel
    private var cancellables = Set<AnyCancellable>()

    var titleText: String {
        if let mediaHeading = currentEpisode?.medias.first?.headingEt, !mediaHeading.isEmpty {
            return mediaHeading
        } else if let episodeHeading = currentEpisode?.heading {
            return episodeHeading
        } else {
            return ""
        }
    }

    var bodyText: String {
        if let rawBody = currentEpisode?.medias.first?.bodyEt {
            return rawBody.replacingOccurrences(of: "\\n", with: "\n")
        } else {
            return ""
        }
    }

    var episodeImageUrl: String {
        if let imageUrl = currentEpisode?.photos.first?.photoUrlBase {
            return imageUrl
        } else {
            return ""
        }
    }

    var contentPublicStart: Int {
        contentItem.publicStart
    }

    init(
        apiService: APIService = .shared,
        audioService: AudioPlayerService = .shared,
        contentItem: ContentItemModel
    ) {
        self.audioService = audioService
        self.apiService = apiService
        self.contentItem = contentItem
        audioService.$state.receive(on: RunLoop.main).assign(to: &$playerState)
        audioService.$currentTime.assign(to: &$currentTime)
        audioService.$duration.assign(to: &$duration)
    }

    @MainActor
    func loadData() async {
        viewState = .loading
        do {
            let episode = try await loadEpisode(id: contentItem.id)
            preparePlayback(from: episode)
        } catch {
            viewState = .failure(error.localizedDescription)
        }
    }

    func playPause() {
        switch playerState {
        case .playing:
            audioService.pause()
        case .paused, .stopped:
            audioService.play()
        default:
            break
        }
    }

    func seek(to time: Double) {
        audioService.seek(to: time)
    }

    func onSeekSliderEditingChanged(_ isEditing: Bool, _ value: Double) {
        if isEditing {
            audioService.pauseObservationLogic()
        } else {
            seek(to: value)
            audioService.resumeObservationLogic(newTime: value)
        }
    }

    @MainActor
    private func loadEpisode(id episodeId: Int) async throws -> EpisodeModel {
        let episodes = try await apiService.getAudioPlayerData(for: episodeId)
        guard let episode = episodes.first else {
            throw AudioPlayerError.episodeNotFound
        }
        return episode
    }

    private func episodeURL(from episode: EpisodeModel) -> URL? {
        guard let mediaPath = episode.medias.first?.src.file ??
                              episode.clips.first?.medias.first?.src.file else { return nil }
        return URL(string: "https:\(mediaPath)")
    }

    private func preparePlayback(from episode: EpisodeModel) {
        currentEpisode = episode
        guard let mediaUrl = episodeURL(from: episode) else {
            let errorMessage = "Invalid episode URL or No playable media found in episode."
            print(errorMessage)
            viewState = .failure(errorMessage)
            return
        }

        let metadata = AudioMetadata(
            title: titleText,
            description: bodyText,
            imageURL: URL(string: episodeImageUrl)
        )

        audioService.load(url: mediaUrl, metadata: metadata)
        viewState = .success
    }
}
