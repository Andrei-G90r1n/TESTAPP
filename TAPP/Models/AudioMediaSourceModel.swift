struct AudioMediaSourceModel: Codable {
    let file: String
    let hls: String
    let dash: String
    let podcastUrl: String?
}
