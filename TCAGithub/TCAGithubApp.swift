//
//  TCAGithubApp.swift
//  TCAGithub
//
//  Created by Oron Ben Zvi on 23/01/2023.
//

import SwiftUI
import FirebaseCore
import FirebaseDatabase
import XCTestDynamicOverlay

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if !_XCTIsTesting {
            FirebaseApp.configure()
        }
        
        return true
    }
}

@main
struct TCAGithubApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            if !_XCTIsTesting {
                SearchView(store: .init(initialState: .init(), reducer: Search()))
            }
        }
    }
}
