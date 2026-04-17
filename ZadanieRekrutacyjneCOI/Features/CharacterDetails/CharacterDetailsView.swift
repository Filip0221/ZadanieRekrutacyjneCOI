//
//  CharacterDetailsView.swift
//  ZadanieRekrutacyjneCOI
//
//  Created by Filip Skup on 16/04/2026.
//
import ComposableArchitecture
import SwiftUI

struct CharacterDetailsView: View {
    let store: StoreOf<CharacterDetailsFeature>
    
    var body: some View {
        ScrollView{
            VStack(spacing: 16) {
                AsyncImage(url: URL(string: store.character.image)) {image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 200, height: 200)
                Text(store.character.name)
                    .font(.title)
                
                Text ("Status: \(store.character.status)")
                Text ("Gender: \(store.character.gender)")
                Text ("Origin: \(store.character.origin.name)")
                Text ("Location: \(store.character.location.name)")
                
                if store.isLoading {
                    ProgressView()
                }
                
                if let error = store.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }
                VStack(alignment: .leading){
                    ForEach(store.episodes){ episode in
                        NavigationLink{
                            EpisodeDetailsView(
                                store: Store(initialState: EpisodeDetailsFeature.State(episodeID: episode.id)){
                                    EpisodeDetailsFeature()
                                })
                        } label: {
                            Text("Odcinek \(episode.episode)")
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .task{
                store.send(.onAppear)
            }
        }
    }
}

#Preview {
    CharacterDetailsView(store: Store(
        initialState: CharacterDetailsFeature.State(
            character: CharacterDTO(
                id: 1,
                name: "Rick Sanchez",
                status: "Alive",
                gender: "Male",
                origin: CharacterLocationDTO(name: "Earth"),
                location: CharacterLocationDTO(name: "Earth"),
                image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
                episode: []
            )
        )
    ) {
        CharacterDetailsFeature()
    })
}
