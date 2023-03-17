//
//  SearchView.swift
//  TCAGithub
//
//  Created by Oron Ben Zvi on 23/01/2023.
//

import SwiftUI
import ComposableArchitecture

struct Search: Reducer {
    @Dependency(\.apiClient.search) var search
    @Dependency(\.continuousClock) var clock
    
    struct State: Equatable {
        @BindingState var query: String = ""
        var items: IdentifiedArrayOf<SearchResponse.Item> = []
        
        @PresentationState var profile: Profile.State?
    }
    
    enum Action: Equatable, BindableAction {
        case searchResponse(TaskResult<SearchResponse>)
        case itemTapped(SearchResponse.Item.ID)
        case profile(PresentationAction<Profile.Action>)
        case binding(BindingAction<State>)
    }
    
    enum CancelID {}
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce<State, Action> { state, action in
            switch action {
            case .binding(\.$query):
                guard state.query != "" else {
                    state.items = []
                    return .cancel(id: CancelID.self)
                }
                return .task { [query = state.query] in
                    try await clock.sleep(for: .seconds(0.3))
                    return await .searchResponse(
                        TaskResult { try await search(query) }
                    )
                }
                .cancellable(id: CancelID.self, cancelInFlight: true)
            case .searchResponse(.success(let response)):
                state.items = .init(uniqueElements: response.items)
                return .none
            case .searchResponse(.failure(let error)):
                print(error)
                return .none
            case .itemTapped(let id):
                guard let item = state.items[id: id] else { return .none }
                state.profile = .init(searchItem: item)
                return .none
            case .profile(_):
                return .none
            case.binding(_):
                return .none
            }
        }
        .ifLet(\.$profile, action: /Action.profile) {
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
                    ForEach(viewStore.items) { item in
                        NavigationLinkStore(
                            store.scope(state: \.$profile, action: Search.Action.profile),
                            id: item.id) {
                                viewStore.send(.itemTapped(item.id))
                            } destination: { store in
                                ProfileView(store: store)
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
                .searchable(text: viewStore.binding(\.$query))
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
