import Foundation

enum APIError: Error, LocalizedError {
    case missingHomeData
    case missingAudioPlayerData

    var errorDescription: String? {
        switch self {
        case .missingHomeData:
            return "Home data missing."
        case .missingAudioPlayerData:
            return "AudioPlayer data missing."
        }
    }
}
