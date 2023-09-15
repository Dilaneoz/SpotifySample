//
//  PlaylistDetailResponse.swift
//  bilgetify2
//
//  Created by Opendart Yazılım ve Bilişim Hizmetleri on 16.04.2023.
//

import Foundation


struct PlaylistDetailsResponse: Codable {
    let description: String
    let external_urls: [String: String]
    let id: String
    let images: [APIImage]
    let name: String
    let tracks: PlaylistTracksResponse
}

struct PlaylistTracksResponse: Codable {
    let items: [PlaylistItem]
}

struct PlaylistItem: Codable {
    let track: AudioTrack
}
