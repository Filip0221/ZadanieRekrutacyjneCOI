//
//  CharactersListSnapshotTests.swift
//  ZadanieRekrutacyjneCOI
//
//  Created by Filip Skup on 17/04/2026.
//

import SnapshotTesting
import Testing
import SwiftUI
import ComposableArchitecture
@testable import ZadanieRekrutacyjneCOI
internal import SwiftData

@MainActor
struct CharactersListSnapshotTests {
    
    @Test
    func list() {
        let view = CharactersListView(
            store: Store(
                initialState: CharactersListFeature.State(
                    characters: [
                        CharacterDTO(
                            id: 1,
                            name: "Rick Sanchez",
                            status: "Alive",
                            gender: "Male",
                            origin: .init(name: "Earth (C-137)"),
                            location: .init(name: "Citadel of Ricks"),
                            image: "",
                            episode: []
                        )
                    ]
                )
            ) {
                CharactersListFeature()
            } withDependencies: {
                $0.apiClient.fetchCharacters = { _, _ in
                    CharacterResponseDTO(
                        info: PageInfoDTO(count: 0, pages: 0, next: nil, prev: nil),
                        results: []
                    )
                }
            }
        )
            .modelContainer(for: FavoriteCharacter.self)
        
        assertSnapshot(
            of: view,
            as: .image(layout: .sizeThatFits)
        )
    }
}
