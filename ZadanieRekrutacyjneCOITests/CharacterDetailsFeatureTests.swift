//
//  CharacterDetailsFeatureTests.swift
//  ZadanieRekrutacyjneCOI
//
//  Created by Filip Skup on 17/04/2026.
//

import Testing
import ComposableArchitecture
@testable import ZadanieRekrutacyjneCOI

struct CharacterDetailsFeatureTests {
    
    @MainActor
    @Test
    func onAppear_loadsEpisodes() async {
        let character = CharacterDTO(
            id: 1,
            name: "Rick",
            status: "Alive",
            gender: "Male",
            origin: .init(name: "Earth"),
            location: .init(name: "Earth"),
            image: "",
            episode: ["https://rickandmortyapi.com/api/episode/1"]
        )

        let episodes = [
            EpisodeDTO(
                id: 1,
                name: "Pilot",
                airDate: "Today",
                episode: "S01E01",
                characters: []
            )
        ]

        let store = TestStore(
            initialState: CharacterDetailsFeature.State(character: character)
        ) {
            CharacterDetailsFeature()
        } withDependencies: {
            $0.apiClient.fetchEpisodes = { _ in episodes }
        }

        await store.send(.onAppear) {
            $0.isLoading = true
        }

        await store.receive(.episodesResponse(.success(episodes))) {
            $0.isLoading = false
            $0.episodes = episodes
        }
    }
}
