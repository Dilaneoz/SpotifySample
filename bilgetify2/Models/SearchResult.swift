//
//  SearchResult.swift
//  bilgetify2
//
//  Created by Opendart Yazılım ve Bilişim Hizmetleri on 8.04.2023.
//

import Foundation
enum SearchResult { // gelen datalara göre, örneğin gelen data artistse artist kategorisini aç, albumse albumu vs, kategorileri göstermek için
    case artist(model: Artist)
    case album(model: Album)
    case track(model: AudioTrack)
    case playlist(model: Playlist)
}
