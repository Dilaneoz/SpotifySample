//
//  AllCategoriesResponse.swift
//  bilgetify2
//
//  Created by Opendart Yazılım ve Bilişim Hizmetleri on 8.04.2023.
//

import Foundation

struct AllCategoriesResponse: Codable {
    let categories: Categories
}

struct Categories: Codable {
    let items: [Category]
}

struct Category: Codable {
    let id: String
    let name: String
    let icons: [APIImage]
}
