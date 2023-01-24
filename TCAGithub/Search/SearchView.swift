//
//  SearchView.swift
//  TCAGithub
//
//  Created by Oron Ben Zvi on 23/01/2023.
//

import SwiftUI
import ComposableArchitecture

struct Search: ReducerProtocol {
    @Dependency(\.apiClient.search) var search
    @Dependency(\.continuousClock) var clock
    
    struct State: Equatable {
        var query: String = ""
        var items: IdentifiedArrayOf<Profile.State> = []
    }
    
    enum Action: Equatable {
        case queryChanged(String)
        case searchResponse(TaskResult<SearchResponse>)
        case profile(id: Int, action: Profile.Action)
    }
    
    enum CancelID {}
    
    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .queryChanged(let query):
                state.query = query
                guard query != "" else {
                    state.items = []
                    return .cancel(id: CancelID.self)
                }
                return .task {
                    try await withTaskCancellation(id: CancelID.self,
                                                   cancelInFlight: true) {
                        try await clock.sleep(for: .seconds(0.3))
                        return await .searchResponse(
                            TaskResult { try await search(query) }
                        )
                    }
                }
            case .searchResponse(.success(let response)):
                state.items = .init(uniqueElements: response.items
                    .map { .init(searchItem: $0) }
                )
                return .none
            case .searchResponse(.failure(let error)):
                print(error)
                return .none
            case .profile(_, _):
                return .none
            }
        }
        .forEach(\.items, action: /Action.profile) {
            Profile()
        }
    }
}

struct SearchView: View {
    let store: StoreOf<Search>
    
    var body: some View {
        NavigationView {
            WithViewStore(store, observe: { $0 }) { viewStore in
                List {
                    ForEachStore(store.scope(state: \.items,
                                             action: Search.Action.profile)) { store in
                        NavigationLink {
                            ProfileView(store: store)
                        } label: {
                            WithViewStore(store, observe: { $0 }) { viewStore in
                                HStack {
                                    AsyncImage(url: viewStore.searchItem.avatarUrl) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 40, height: 40)
                                    .cornerRadius(20)
                                    Text(viewStore.searchItem.login)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Search")
                .searchable(text: viewStore.binding(
                    get: \.query,
                    send: Search.Action.queryChanged)
                )
                .autocorrectionDisabled()
            }
            .onAppear {
                URLCache.shared.memoryCapacity = 10_000_000 // ~10 MB memory space
                URLCache.shared.diskCapacity = 1_000_000_000 // ~1GB disk cache space
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(store: .init(initialState: .init(), reducer: Search()))
    }
}
