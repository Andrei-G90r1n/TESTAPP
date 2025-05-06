struct MediaModel: Codable {
    let id: Int
    let type: String
    let headingEt: String
    let bodyEt: String?
    let podcastUrl: String?
    let file: String
    let src: AudioMediaSourceModel
}
