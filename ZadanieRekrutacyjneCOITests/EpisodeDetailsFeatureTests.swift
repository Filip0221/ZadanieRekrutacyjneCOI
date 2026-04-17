//
//  EpisodeDetailsFeatureTests.swift
//  ZadanieRekrutacyjneCOI
//
//  Created by Filip Skup on 17/04/2026.
//

import Testing
import ComposableArchitecture
@testable import ZadanieRekrutacyjneCOI

struct EpisodeDetailsFeatureTests {
    
    @Test
    @MainActor
    func onAppear_loadsEpisode() async {
        let episode = EpisodeDTO(
            id: 1,
            name: "Pilot",
            airDate: "Today",
            episode: "S01E01",
            characters: [
                "https://rickandmortyapi.com/api/character/1"
            ]
        )
        
        let characters = [
            CharacterDTO(
                id: 1,
                name: "Rick Sanchez",
                status: "Alive",
                gender: "Male",
                origin: .init(name: "Earth (C-137)"),
                location: .init(name: "Citadel of Ricks"),
                image: "https://rickandmortyapi.com/api/character/avatar/1.jpeg",
                episode: [
                    "https://rickandmortyapi.com/api/episode/1",
                    "https://rickandmortyapi.com/api/episode/2",
                    "https://rickandmortyapi.com/api/episode/3",
                    "https://rickandmortyapi.com/api/episode/4",
                    "https://rickandmortyapi.com/api/episode/5",
                    "https://rickandmortyapi.com/api/episode/6",
                    "https://rickandmortyapi.com/api/episode/7",
                    "https://rickandmortyapi.com/api/episode/8",
                    "https://rickandmortyapi.com/api/episode/9",
                    "https://rickandmortyapi.com/api/episode/10",
                    "https://rickandmortyapi.com/api/episode/11",
                    "https://rickandmortyapi.com/api/episode/12",
                    "https://rickandmortyapi.com/api/episode/13",
                    "https://rickandmortyapi.com/api/episode/14",
                    "https://rickandmortyapi.com/api/episode/15",
                    "https://rickandmortyapi.com/api/episode/16",
                    "https://rickandmortyapi.com/api/episode/17",
                    "https://rickandmortyapi.com/api/episode/18",
                    "https://rickandmortyapi.com/api/episode/19",
                    "https://rickandmortyapi.com/api/episode/20",
                    "https://rickandmortyapi.com/api/episode/21",
                    "https://rickandmortyapi.com/api/episode/22",
                    "https://rickandmortyapi.com/api/episode/23",
                    "https://rickandmortyapi.com/api/episode/24",
                    "https://rickandmortyapi.com/api/episode/25",
                    "https://rickandmortyapi.com/api/episode/26",
                    "https://rickandmortyapi.com/api/episode/27",
                    "https://rickandmortyapi.com/api/episode/28",
                    "https://rickandmortyapi.com/api/episode/29",
                    "https://rickandmortyapi.com/api/episode/30",
                    "https://rickandmortyapi.com/api/episode/31",
                    "https://rickandmortyapi.com/api/episode/32",
                    "https://rickandmortyapi.com/api/episode/33",
                    "https://rickandmortyapi.com/api/episode/34",
                    "https://rickandmortyapi.com/api/episode/35",
                    "https://rickandmortyapi.com/api/episode/36",
                    "https://rickandmortyapi.com/api/episode/37",
                    "https://rickandmortyapi.com/api/episode/38",
                    "https://rickandmortyapi.com/api/episode/39",
                    "https://rickandmortyapi.com/api/episode/40",
                    "https://rickandmortyapi.com/api/episode/41",
                    "https://rickandmortyapi.com/api/episode/42",
                    "https://rickandmortyapi.com/api/episode/43",
                    "https://rickandmortyapi.com/api/episode/44",
                    "https://rickandmortyapi.com/api/episode/45",
                    "https://rickandmortyapi.com/api/episode/46",
                    "https://rickandmortyapi.com/api/episode/47",
                    "https://rickandmortyapi.com/api/episode/48",
                    "https://rickandmortyapi.com/api/episode/49",
                    "https://rickandmortyapi.com/api/episode/50",
                    "https://rickandmortyapi.com/api/episode/51"
                ]
            )
        ]
        
        let store = TestStore(
            initialState: EpisodeDetailsFeature.State(episodeID: 1)
        ) {
            EpisodeDetailsFeature()
        } withDependencies: {
            $0.apiClient.fetchEpisode = { _ in episode }
            $0.apiClient.fetchCharacters = { _, _ in
                CharacterResponseDTO(
                    info: PageInfoDTO(count: 1, pages: 1, next: nil, prev: nil),
                    results: characters
                )
            }
        }
        
        await store.send(.onAppear) {
            $0.isLoading = true
        }
        
        await store.receive(.episodeResponse(.success(episode))) {
            $0.isLoading = false
            $0.episode = episode
        }
        
        await store.receive(.charactersResponse(.success(characters))) {
            $0.isLoading = false
            $0.characters = characters
        }
    }
}
