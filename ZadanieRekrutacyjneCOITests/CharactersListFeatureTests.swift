//
//  CharactersListFeatureTests.swift
//  ZadanieRekrutacyjneCOITests
//
//  Created by Filip Skup on 17/04/2026.
//

import Testing
import ComposableArchitecture
@testable import ZadanieRekrutacyjneCOI
internal import Foundation

struct CharactersListFeatureTests {
    
    @MainActor
    @Test
    func toggleFavorite_addsAndRemoves() async {
        let store = TestStore(
            initialState: CharactersListFeature.State()
        ) {
            CharactersListFeature()
        }

        await store.send(.toggleFavorite(1)) {
            $0.favoriteIDs.insert(1)
        }

        await store.send(.toggleFavorite(1)) {
            $0.favoriteIDs.remove(1)
        }
    }

    @MainActor
    @Test
    func onAppear_failure_setsError() async {
        let store = TestStore(
            initialState: CharactersListFeature.State()
        ) {
            CharactersListFeature()
        } withDependencies: {
            $0.apiClient.fetchCharacters = { _, _ in
                throw APIError.invalidResponse
            }
        }

        await store.send(.onAppear) {
            $0.isLoading = true
        }

        await store.receive(.characterResponse(.failure(.invalidResponse))) {
            $0.isLoading = false
            $0.errorMessage = APIError.invalidResponse.localizedDescription
        }
    }
    
    
    @MainActor
    @Test
    func loadNextPage_blocked_whenLoading() async {
        let store = TestStore(
            initialState: CharactersListFeature.State(
                isLoading: true,
                canLoadMore: true
            )
        ) {
            CharactersListFeature()
        }

        await store.send(.loadNextPage)
    }
}
