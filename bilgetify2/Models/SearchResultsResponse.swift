//
//  SearchResultResponse.swift
//  bilgetify2
//
//  Created by Opendart Yazılım ve Bilişim Hizmetleri on 8.04.2023.
//

import Foundation
//composit bir obje döner
//arama yaptığımızda dönen sonuçlara karşılık bu struct yapısı karşılayacak
//restapi den gelen dataları ilk olarak burada veri modelimizle ilişkilendiricez

//composit bir obje döner
//arama yaptığımızda dönen sonuçlara karşılık bu struct yapısı karşılayacak

struct SearchResultsResponse : Codable {
    let albums : SearchAlbumResponse
    let artists : SearchArtistsResponse
    let playlists : SearchPlayListResponse
    let tracks : SearchTrackssResponse
    
}


struct SearchAlbumResponse : Codable {
    let items : [Album]
}

struct SearchArtistsResponse : Codable {
    let items : [Artist]
}

struct SearchPlayListResponse : Codable {
    let items : [Playlist]
}

struct SearchTrackssResponse : Codable {
    let items : [AudioTrack]
}
