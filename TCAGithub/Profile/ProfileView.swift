//
//  ProfileView.swift
//  TCAGithub
//
//  Created by Oron Ben Zvi on 23/01/2023.
//

import SwiftUI
import ComposableArchitecture

struct Profile: Reducer {
    @Dependency(\.apiClient.user) var user
    
    struct State: Equatable, Identifiable {
        var searchItem: SearchResponse.Item
        var user: UserResponse?
        
        @PresentationState var comments: Comments.State?
        
        var id: Int {
            searchItem.id
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case userResponse(TaskResult<UserResponse>)
        case showCommentsTapped
        case comments(PresentationAction<Comments.Action>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .task { [url = state.searchItem.url] in
                    await .userResponse(
                        TaskResult { try await user(url) }
                    )
                }
            case .userResponse(.success(let response)):
                state.user = response
                return .none
            case .userResponse(.failure(let error)):
                print(error)
                return .none
            case .showCommentsTapped:
                state.comments = .init(username: state.searchItem.login)
                return .none
            case .comments(_):
                return .none
            }
        }
        .ifLet(\.$comments, action: /Action.comments) {
            Comments()
        }
    }
}

struct ProfileView: View {
    let store: StoreOf<Profile>
    
    struct ViewState: Equatable {
        let searchItem: SearchResponse.Item
        let user: UserResponse?
    }
    
    var body: some View {
        WithViewStore(store, observe: { ViewState(searchItem: $0.searchItem, user: $0.user) }) { viewStore in
            VStack {
                AsyncImage(url: viewStore.searchItem.avatarUrl) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .padding(40)
                } placeholder: {
                    ProgressView()
                }
                .frame(maxWidth: .infinity)
                            
                if let name = viewStore.user?.name {
                    Text(name)
                        .font(.largeTitle)
                } else {
                    Text(viewStore.searchItem.login)
                        .redacted(reason: viewStore.user == nil ? .placeholder : [])
                        .font(.largeTitle)
                }
                
                Text("\(viewStore.user?.followers ?? 0) followers")
                
                Spacer()
                
                Button {
                    viewStore.send(.showCommentsTapped)
                } label: {
                    Text("Show comments")
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .padding()
            }
            .sheet(store: store.scope(state: \.$comments, action: Profile.Action.comments)) { store in
                CommentsView(store: store)
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(store: .init(initialState: .init(searchItem: .mock),
                                 reducer: Profile()))
    }
}
