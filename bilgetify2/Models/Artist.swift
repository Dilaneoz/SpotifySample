//
//  Artist.swift
//  bilgetify2
//
//  Created by Opendart Yazılım ve Bilişim Hizmetleri on 8.04.2023.
//

import Foundation
struct Artist: Codable {
    let id: String
    let name: String
    let type: String
    let images: [APIImage]?
    let external_urls: [String: String] // iki boyutlu bir array. anahtar ve değeri şeklinde veri tutmamızı sağlayan dictionary dediğimiz bir yapı
}
