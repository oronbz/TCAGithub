//
//  CommentsView.swift
//  TCAGithub
//
//  Created by Oron Ben Zvi on 23/01/2023.
//

import SwiftUI
import ComposableArchitecture

struct Comments: ReducerProtocol {
    @Dependency(\.commentService) var commentService;
    
    struct State: Equatable {
        var username: String
        var comments: IdentifiedArrayOf<Comment> = []
        var comment: String = ""
    }
    
    enum Action: Equatable {
        case task
        case commentsChanged([Comment])
        case setComment(String)
        case onSubmit
        case closeTapped
    }
    
    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                return .run { [username = state.username] send in
                    for await comments in commentService.comments(username) {
                        await send(.commentsChanged(comments))
                    }
                }
            case .commentsChanged(let comments):
                state.comments = .init(uniqueElements: comments)
                return .none
            case .setComment(let comment):
                state.comment = comment
                return .none
            case .onSubmit:
                commentService.add(state.username, state.comment)
                state.comment = ""
                return .none
            case .closeTapped:
                return .none
            }
        }
    }
}

struct CommentsView: View {
    let store: StoreOf<Comments>
    
    var body: some View {
        NavigationView {
            WithViewStore(store, observe: { $0 }) { viewStore in
                VStack {
                    List {
                        ForEach(viewStore.comments) { comment in
                            Text(comment.content)
                        }
                    }
                    .scrollDismissesKeyboard(.immediately)
                    
                    TextField("Awesome comment...", text: viewStore.binding(
                        get: \.comment,
                        send: Comments.Action.setComment))
                        .onSubmit {
                            viewStore.send(.onSubmit)
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 15)
                                    .stroke(.yellow, lineWidth: 2))
                        .background(Color(uiColor: .systemBackground))
                        .padding(10)

                }
                .navigationTitle("Comments")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    Button {
                        viewStore.send(.closeTapped)
                    } label: {
                        Image(systemName: "chevron.down")
                    }

                }
                .task {
                    await viewStore.send(.task).finish()
                }
            }
        }
    }
}

struct CommentsView_Previews: PreviewProvider {
    static var previews: some View {
        CommentsView(store: .init(initialState: .init(username: "oronbz"),
                                  reducer: Comments()))
    }
}
