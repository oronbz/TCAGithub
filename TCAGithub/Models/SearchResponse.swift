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
    struct Item: Equatable, Codable, Identifiable {
        let id: Int
        let login: String
        let avatarUrl: URL
        let url: URL
    }
}

extension SearchResponse.Item {
    static let mock = Self(id: 123,
                           login: "oronbz",
                           avatarUrl: .init(string: "https://avatars.githubusercontent.com/u/1288090?v=4")!,
                           url: .init(string: "https://api.github.com/users/oronbz")!)

}
