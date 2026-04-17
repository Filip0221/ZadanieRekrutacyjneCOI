//
//  EpisodeDetailsView.swift
//  ZadanieRekrutacyjneCOI
//
//  Created by Filip Skup on 17/04/2026.
//

import SwiftUI
import ComposableArchitecture

struct EpisodeDetailsView: View {
    let store: StoreOf<EpisodeDetailsFeature>
    
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack(spacing: 16){
                    if store.isLoading {
                        ProgressView()
                    }
                    
                    if let episode = store.episode {
                        Text(episode.name)
                            .font(.title)
                            .bold()
                        Text("Data premiery: \(episode.airDate)")
                            .italic()
                        Text("Ocinek: \(episode.episode)")
                        DisclosureGroup("Lista bohaterów"){
                            ForEach(store.characters) {character in
                                NavigationLink {
                                    CharacterDetailsView(
                                        store: Store(
                                            initialState: CharacterDetailsFeature.State(character: character)
                                        ) {
                                            CharacterDetailsFeature()
                                        }
                                    )
                                } label: {
                                    Text(character.name)
                                        .padding(.vertical, 5)
                                }
                            }
                        }
                        .padding(.horizontal, 10)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                        Spacer()
                        
                    }
                    if let error = store.errorMessage{
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .navigationTitle("Odcinek")
                .task{
                    store.send(.onAppear)
                }
            }
        }
    }
}

#Preview {
    EpisodeDetailsView(store: Store(
        initialState: EpisodeDetailsFeature.State(
            episodeID: 1
        )
    ){
        EpisodeDetailsFeature()
    }
    )
}
