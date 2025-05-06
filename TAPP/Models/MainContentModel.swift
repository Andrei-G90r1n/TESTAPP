struct MainContentModel: Codable {
    let id: Int
    let heading: String
    let photos: [PhotoType]
    let medias: [MediaModel]
}
