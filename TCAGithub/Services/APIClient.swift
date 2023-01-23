//
//  APIClient.swift
//  TCAGithub
//
//  Created by Oron Ben Zvi on 23/01/2023.
//

import Foundation
import Dependencies

struct APIClient {
    var search: (_ query: String) async throws -> SearchResponse
}

extension APIClient: DependencyKey {
    static var liveValue: APIClient {
        @Dependency(\.urlSession) var urlSession
        
        return Self(
            search: { query in
                let url = URL(string: "https://api.github.com/search/users?q=\(query)")!
                var urlRequest = URLRequest(url: url)
                urlRequest.addValue("Bearer \(Key.github)", forHTTPHeaderField: "Authorization")
                let (data, _) = try await urlSession.data(for: urlRequest)
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return try decoder.decode(SearchResponse.self, from: data)
            }
        )
    }
    
    static var previewValue: APIClient {
        Self(
            search: { query in
                SearchResponse(items: [
                    .init(id: 123,
                          login: "oronbz",
                          avatarUrl: .init(string: "https://avatars.githubusercontent.com/u/1288090?v=4")!,
                          url: .init(string: "https://api.github.com/users/oronbz")!)
                ])
            }
        )
    }
}

extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}
