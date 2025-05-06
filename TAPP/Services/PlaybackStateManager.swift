import Foundation

class PlaybackStateManager {
    private static let stateKey = "lastPlaybackState"

    static func save(state: PlaybackState) {
        do {
            let data = try JSONEncoder().encode(state)
            UserDefaults.standard.set(data, forKey: stateKey)
        } catch {
            print("Error: \(error)")
        }
    }

    static func load() -> PlaybackState? {
        guard let data = UserDefaults.standard.data(forKey: stateKey) else {
            return nil
        }

        do {
            let state = try JSONDecoder().decode(PlaybackState.self, from: data)
            return state
        } catch {
            print("Error: \(error)")
            return nil
        }
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: stateKey)
    }

    static func exists() -> Bool {
        return UserDefaults.standard.data(forKey: stateKey) != nil
    }
}
