import Foundation

class APIService {
    static let shared = APIService()
    let homeDataUrl = "https://services.err.ee/api/v2/radio/getByUrl?domain=eesti-raadio.err.ee&url=app"
    let audioPlayerDataUrl = "https://services.err.ee/api/v2/radioAppContent/getContentPageData"

    func getHomeData() async throws -> [ContentSectionModel] {
        guard let url = URL(string: homeDataUrl) else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let homeDataResponse = try decoder.decode(HomeDataResponse.self, from: data)
            guard let sectionsData = homeDataResponse.data.category?.frontPage else {
                throw APIError.missingHomeData
            }
            return sectionsData
        } catch {
            print("Error:", error)
        }
        return []
    }

    func getAudioPlayerData(for contentId: Int) async throws -> [EpisodeModel] {
        guard let url = URL(string: "\(audioPlayerDataUrl)?contentId=\(contentId)") else {
            throw URLError(.badURL)
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let playerDataResponse = try decoder.decode(PlayerDataResponse.self, from: data)
            guard let episodeListData = playerDataResponse.data.episodeList else {
                throw APIError.missingAudioPlayerData
            }
            return episodeListData
        } catch {
            print("Error:", error)
        }
        return []
    }
}
