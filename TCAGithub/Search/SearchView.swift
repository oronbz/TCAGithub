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
    
    struct State: Equatable {
        var query: String = ""
        var items: IdentifiedArrayOf<SearchResponse.Item> = []
    }
    
    enum Action: Equatable {
        case queryChanged(String)
        case searchResponse(TaskResult<SearchResponse>)
    }
    
    var body: some ReducerProtocolOf<Self> {
        Reduce { state, action in
            switch action {
            case .queryChanged(let query):
                state.query = query
                guard query != "" else {
                    state.items = []
                    return .none
                }
                return .task {
                    await .searchResponse(TaskResult { try await search(query) })
                }
            case .searchResponse(.success(let response)):
                state.items = .init(uniqueElements: response.items)
                return .none
            case .searchResponse(.failure(let error)):
                print(error)
                return .none
            }
        }
    }
}

struct SearchView: View {
    let store: StoreOf<Search>
    
    let names = (0..<30)
        .map { "Username \($0)" }
    
    var body: some View {
        NavigationView {
            WithViewStore(store, observe: { $0 }) { viewStore in
                List {
                    ForEach(viewStore.items) { item in
                        NavigationLink {
                            ProfileView()
                        } label: {
                            HStack {
                                AsyncImage(url: item.avatarUrl) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 40, height: 40)
                                .cornerRadius(20)
                                Text(item.login)
                                Spacer()
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
