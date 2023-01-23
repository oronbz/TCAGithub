//
//  SearchResponse.swift
//  TCAGithub
//
//  Created by Oron Ben Zvi on 23/01/2023.
//

import Foundation

/// https://api.github.com/search/users?q=oronbz

struct SearchResponse: Equatable, Codable {
    let items: [Item]
}

extension SearchResponse {
    struct Item: Equatable, Codable {
        let id: Int
        let login: String
        let avatarUrl: URL
        let url: URL
    }
}
