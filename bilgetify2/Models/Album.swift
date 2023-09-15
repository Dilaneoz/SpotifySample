//
//  Album.swift
//  bilgetify2
//
//  Created by Opendart Yazılım ve Bilişim Hizmetleri on 8.04.2023.
//

import Foundation
struct NewReleasesResponse: Codable { // bize albumlerle ilgili bir restapi servisi geldiğinde
    let albums: AlbumsResponse
}

struct AlbumsResponse: Codable {
    let items: [Album] // items diye bir array gelicek
}

struct Album: Codable { // items array inin içerisinde de her bir albumu temsil eden veriler olucak
    let album_type: String
    let available_markets: [String]
    let id: String
    var images: [APIImage]
    let name: String
    let release_date: String
    let total_tracks: Int
    let artists: [Artist]
}
