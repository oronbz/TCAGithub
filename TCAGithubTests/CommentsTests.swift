//
//  CommentsTests.swift
//  TCAGithubTests
//
//  Created by Oron Ben Zvi on 17/03/2023.
//

import XCTest
import ComposableArchitecture

@testable import TCAGithub

@MainActor
final class CommentsTests: XCTestCase {
    func testCloseButton() async {
        let didDismiss = ActorIsolated<Bool>(false)
        let expectation = expectation(description: "Dismissed")
        
        let store = TestStore(initialState: Comments.State(username: "oronbz"), reducer: Comments()) {
            $0.dismiss = DismissEffect {
                
                await didDismiss.setValue(true)
                expectation.fulfill()
            }
        }
        
        await store.send(.closeTapped)
        
        waitForExpectations(timeout: 1)
        
        wait
                
        await didDismiss.withValue { dismissed in
            XCTAssertTrue(dismissed)
        }
    }
}
