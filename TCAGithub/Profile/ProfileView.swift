//
//  ProfileView.swift
//  TCAGithub
//
//  Created by Oron Ben Zvi on 23/01/2023.
//

import SwiftUI
import ComposableArchitecture

struct Profile: ReducerProtocol {
    @Dependency(\.apiClient.user) var user
    
    struct State: Equatable, Identifiable {
        var searchItem: SearchResponse.Item
        var user: UserResponse?
        var isCommentsPresened = false
        
        var id: Int {
            searchItem.id
        }
    }
    
    enum Action: Equatable {
        case onAppear
        case showCommentsTapped
        case setComments(isPresented: Bool)
    }
    
    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .showCommentsTapped:
                state.isCommentsPresened = true
                return .none
            case .setComments(let isPresented):
                state.isCommentsPresened = isPresented
                return .none
            }
        }
    }
}

struct ProfileView: View {
    let store: StoreOf<Profile>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                AsyncImage(url: viewStore.searchItem.avatarUrl) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(maxWidth: .infinity)
                            
                if let name = viewStore.user?.name {
                    Text(name)
                        .font(.largeTitle)
                } else {
                    Text(viewStore.searchItem.login)
                        .redacted(reason: .placeholder)
                        .font(.largeTitle)
                }
                
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
            .sheet(isPresented: viewStore.binding(
                get: \.isCommentsPresened,
                send: Profile.Action.setComments)
            ) {
                CommentsView()
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
