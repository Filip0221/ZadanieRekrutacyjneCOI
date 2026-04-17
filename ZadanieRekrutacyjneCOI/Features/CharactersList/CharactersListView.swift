//
//  CharactersListView.swift
//  ZadanieRekrutacyjneCOI
//
//  Created by Filip Skup on 16/04/2026.
//

import SwiftUI
import ComposableArchitecture
import SwiftData

struct CharactersListView: View {
    let store: StoreOf<CharactersListFeature>
    @Environment(\.modelContext) private var context
    @Query private var favorites: [FavoriteCharacter]
    
    var body: some View {
        NavigationStack {
            List {
                let characters = store.characters
                ForEach(store.characters) { character in
                    NavigationLink{
                        CharacterDetailsView(store: Store(initialState: CharacterDetailsFeature.State(character: character)){
                            CharacterDetailsFeature()
                        })
                    } label: {
                        HStack{
                            Text(character.name)
                                .onAppear {
                                    guard character.id == characters.last?.id else { return }
                                    store.send(.loadNextPage)
                                }
                            Spacer()
                            Button {
                                if let existing = favorites.first(where: { $0.id == character.id }) {
                                    context.delete(existing)
                                } else {
                                    context.insert(FavoriteCharacter(id: character.id))
                                }
                            } label: {
                                Image(systemName: favorites.contains(where: { $0.id == character.id }) ? "star.fill" : "star")
                                    .foregroundStyle(.yellow)
                            }
                            .buttonStyle(.borderless)
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
            
            if store.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Bohaterowie")
        .task {
            let ids = Set(favorites.map {$0.id})
            store.send(.setFavorites(ids))
            await store.send(.onAppear).finish()
        }
        .onChange(of: favorites) {
            let ids = Set(favorites.map { $0.id })
            store.send(.setFavorites(ids))
        }
        .refreshable { await store.send(.refresh).finish() }
        .searchable(text: Binding(
            get: { store.searchText },
            set: { store.send(.searchChanged($0)) }
        ))
    }

}

#Preview{
    CharactersListView(
        store: Store(initialState: CharactersListFeature.State()){
            CharactersListFeature()
        }
    )
}
