import AVFoundation
import Combine
import MediaPlayer

class AudioPlayerService: ObservableObject {
    enum PlayerState: Equatable {
        case idle
        case loading
        case playing
        case paused
        case stopped
        case error(String)
    }

    @Published var state: PlayerState = .idle
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0

    private var player: AVPlayer?
    private var timeObserverToken: Any?

    static let shared = AudioPlayerService()
    var currentMetadata: AudioMetadata?

    private init() {
        configureAudioSession()
        setupRemoteCommandCenter()
    }

    func updateNowPlayingInfo() {
        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: currentMetadata?.title ?? "",
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPNowPlayingInfoPropertyPlaybackRate: (state == .playing ? 1.0 : 0.0)
        ]

        Task {
            if let url = currentMetadata?.imageURL {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if let image = UIImage(data: data) {
                        let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                        nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                    }
                } catch {
                    print("Failed to load artwork image: \(error)")
                }
            }
        }
    }

    func load(url: URL, metadata: AudioMetadata) {
        currentMetadata = metadata
        currentTime = 0
        duration = 0

        state = .loading
        player?.pause()
        removeObservers()
        player = nil

        player = AVPlayer(url: url)
        addObservers()
        player?.play()
        state = .playing

        updatePlaybackState()
    }

    func play() {
        guard let player = player else {
            return
        }
        player.play()
        state = .playing
        updatePlaybackState()
    }

    func pause() {
        guard let player = player else {
            return
        }
        player.pause()
        state = .paused
        updatePlaybackState()
    }

    func seek(to time: TimeInterval) {
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = time
        let newTime = CMTime(seconds: time, preferredTimescale: 1)
        player?.seek(to: newTime)

        updatePlaybackState()
    }

    func pauseObservationLogic() {
        removeObservers()
        currentTime = 0
    }
    func resumeObservationLogic(newTime: Double) {
        currentTime = newTime
        addObservers()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error: \(error)")
        }
    }

    private func setupRemoteCommandCenter() {

        // Play
        MPRemoteCommandCenter.shared().playCommand.isEnabled = true
        MPRemoteCommandCenter.shared().playCommand.addTarget { _ in
            self.play()
            return .success
        }

        // Pause
        MPRemoteCommandCenter.shared().pauseCommand.isEnabled = true
        MPRemoteCommandCenter.shared().pauseCommand.addTarget { _ in
            self.pause()
            return .success
        }

        // PlaybackPosition
        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.isEnabled = true
        MPRemoteCommandCenter.shared().changePlaybackPositionCommand.addTarget { event in
            guard let seekEvent = event as? MPChangePlaybackPositionCommandEvent else {
                return .commandFailed
            }
            self.seek(to: seekEvent.positionTime)
            return .success
        }
    }

    private func addObservers() {
        guard let player = player else {
            return
        }

        timeObserverToken = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 1, preferredTimescale: 600),
            queue: .main
        ) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = time.seconds
            self.updatePlaybackState()
        }

        player.currentItem?.publisher(for: \.duration)
            .compactMap { $0.isIndefinite ? nil : $0.seconds }
            .receive(on: RunLoop.main)
            .assign(to: &$duration)
    }

    private func savePlaybackState() {
        guard let currentMetadata, let player else { return }
        guard let asset = player.currentItem?.asset as? AVURLAsset else { return }
        let url = asset.url
        let state = PlaybackState(
            streamUrl: url,
            position: currentTime,
            metadata: currentMetadata
        )
        PlaybackStateManager.save(state: state)
    }

    private func updatePlaybackState() {
        updateNowPlayingInfo()
        savePlaybackState()
    }

    private func removeObservers() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }

    deinit {
        removeObservers()
        state = .stopped
    }
}
