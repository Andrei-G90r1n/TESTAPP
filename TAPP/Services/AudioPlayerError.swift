import Foundation

enum AudioPlayerError: Error, LocalizedError {
    case episodeNotFound
    case invalidURL

    var errorDescription: String? {
        switch self {
        case .episodeNotFound:
            return "Episode not found"
        case .invalidURL:
            return "Invalid episode URL or no playable media found."
        }
    }
}
