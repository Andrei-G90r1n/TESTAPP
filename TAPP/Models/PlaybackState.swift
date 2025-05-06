import Foundation

struct PlaybackState: Codable {
    let streamUrl: URL?
    let position: TimeInterval
    let metadata: AudioMetadata
}
