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
    var user: (_ url: URL) async throws -> UserResponse
}

extension APIClient: DependencyKey {
    static var liveValue: APIClient {
        @Dependency(\.urlSession) var urlSession
        
        var decoder: JSONDecoder {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return decoder
        }
        
        return Self(
            search: { query in
                var urlComponents = URLComponents(string: "https://api.github.com/search/users")!
                urlComponents.queryItems = [
                    .init(name: "q", value: query)
                ]
                var urlRequest = URLRequest(url: urlComponents.url!)
                urlRequest.addValue("Bearer \(Key.github)", forHTTPHeaderField: "Authorization")
                let (data, _) = try await urlSession.data(for: urlRequest)
                return try decoder.decode(SearchResponse.self, from: data)
            },
            user: { url in
                var urlRequest = URLRequest(url: url)
                urlRequest.addValue("Bearer \(Key.github)", forHTTPHeaderField: "Authorization")
                let (data, _) = try await urlSession.data(for: urlRequest)
                return try decoder.decode(UserResponse.self, from: data)
            }
        )
    }
    
    static var previewValue: APIClient {
        Self(
            search: { _ in
                SearchResponse(items: [.mock])
            },
            user: { _ in
                UserResponse(id: 123, name: "Oron Ben Zvi", followers: 2)
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
