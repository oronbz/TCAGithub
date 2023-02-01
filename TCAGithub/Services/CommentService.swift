//
//  CommentService.swift
//  TCAGithub
//
//  Created by Oron Ben Zvi on 25/01/2023.
//

import Foundation
import Dependencies
import FirebaseDatabase

struct CommentService {
    var add: (_ comment: String, _ username: String) async -> Void
    var comments: (_ username: String) -> AsyncStream<[Comment]>
}

extension CommentService: DependencyKey {
    static var liveValue: CommentService {
        let commentsRef = Database.database(url: "https://tcagithub-default-rtdb.europe-west1.firebasedatabase.app/")
            .reference()
            .child("comments")
                
        return Self(
            add: { username, comment in
                commentsRef.child(username).childByAutoId().setValue(comment)
            },
            comments: { username in
                AsyncStream { continuation in
                    let userRef = commentsRef.child(username)
                    let refHandle = userRef.observe(.value) { snapshot in
                        let comments = snapshot.children
                            .compactMap { child -> Comment? in
                                guard let snapshot = child as? DataSnapshot,
                                      let content = snapshot.value as? String else { return nil }
                                return Comment(id: snapshot.key, content: content)
                            }
                        
                        continuation.yield(comments)
                    }
                    
                    continuation.onTermination = { _ in
                        userRef.removeObserver(withHandle: refHandle)
                    }
                }
            }
        )
    }
    
    static var previewValue: CommentService {
        Self(
            add: { _, _ in },
            comments: { _ in
                AsyncStream { continuation in
                    continuation.yield([
                        .init(id: "1", content: "First Comment"),
                        .init(id: "2", content: "Second Comment"),
                        .init(id: "3", content: "Third Comment")
                    ])
                    continuation.finish()
                }
            }
        )
    }
}

extension DependencyValues {
    var commentService: CommentService {
        get { self[CommentService.self] }
        set { self[CommentService.self] = newValue }
    }
}
