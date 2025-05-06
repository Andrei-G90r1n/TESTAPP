struct PhotoModel: Codable {
    let id: Int
    let captionEt: String
    let authorEt: String
    let photoUrlOriginal: String
    let photoUrlBase: String
    let photoTypes: [String: PhotoType]
}
