struct EpisodeModel: Codable, Identifiable {
    let id: Int
    let heading: String
    let subHeading: String?
    let photos: [PhotoModel]
    let clips: [ClipModel]
    let medias: [MediaModel]
}
