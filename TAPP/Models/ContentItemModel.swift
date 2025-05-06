struct ContentItemModel: Codable, Identifiable {
    let id: Int
    let publicStart: Int
    let heading: String
    let photos: [PhotoModel]
}
