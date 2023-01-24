//
//  UserResponse.swift
//  TCAGithub
//
//  Created by Oron Ben Zvi on 24/01/2023.
//

import Foundation

/// https://api.github.com/users/oronbz

struct UserResponse: Equatable, Codable  {
    let id: Int
    let name: String?
    let followers: Int
}
