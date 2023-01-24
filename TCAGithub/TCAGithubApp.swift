//
//  TCAGithubApp.swift
//  TCAGithub
//
//  Created by Oron Ben Zvi on 23/01/2023.
//

import SwiftUI

@main
struct TCAGithubApp: App {
    var body: some Scene {
        WindowGroup {
            SearchView(store: .init(initialState: .init(), reducer: Search()))
        }
    }
}
