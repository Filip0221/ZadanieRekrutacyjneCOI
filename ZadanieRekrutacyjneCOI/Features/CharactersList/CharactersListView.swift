//
//  CharactersListView.swift
//  ZadanieRekrutacyjneCOI
//
//  Created by Filip Skup on 16/04/2026.
//

import SwiftUI
import ComposableArchitecture

struct CharactersListView: View {
    let store: StoreOf<CharactersListFeature>
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(store.characters) { character in
                    NavigationLink{
                        CharacterDetailsView(store: Store(initialState: CharacterDetailsFeature.State(character: character)){
                            CharacterDetailsFeature()
                        })
                    } label: {
                    Text(character.name)
                        .onAppear {
                            guard character.id == store.characters.last?.id else {return}
                                store.send(.loadNextPage)
                        }
                }
            }
            
            if store.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Characters")
        .task { await store.send(.onAppear).finish() }
        .refreshable { await store.send(.refresh).finish() }
        .searchable(text: Binding(
            get: { store.searchText },
            set: { store.send(.searchChanged($0)) }
        ))
    }
}
}
