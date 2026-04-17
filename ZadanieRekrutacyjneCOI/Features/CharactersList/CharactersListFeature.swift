//
//  CharactersListFeature.swift
//  ZadanieRekrutacyjneCOI
//
//  Created by Filip Skup on 13/04/2026.
//
import ComposableArchitecture
import SwiftUI

@Reducer
struct CharactersListFeature {
    @ObservableState
    struct State: Equatable{
        var characters: [CharacterDTO] = []
        var page: Int = 1
        var isLoading: Bool = false
        var canLoadMore: Bool = true
        var searchText: String = ""
        var errorMessage: String? = nil
        var favoriteIDs: Set<Int> = []
    }
    
    enum Action: Equatable {
        case onAppear
        case characterResponse(Result<CharacterResponseDTO, APIError>)
        case loadNextPage
        case refresh
        case searchChanged(String)
        case toggleFavorite(Int)
        case setFavorites(Set<Int>)
    }
    @Dependency(\.apiClient) var apiClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            
            switch action {
                // first load
            case .onAppear:
                state.isLoading = true
                state.errorMessage = nil
                
                return .run {
                    send in
                    do {
                        let response = try await apiClient.fetchCharacters(1, nil)
                        await send(.characterResponse(.success(response)))
                    } catch let error as APIError {
                        await send(.characterResponse(.failure(error)))
                    } catch {
                        await send(.characterResponse(.failure(.invalidResponse)))
                    }
                }
                // success
            case let .characterResponse(.success(response)):
                state.isLoading = false
                let newCharacters = response.results.filter{newCharacter in
                    !state.characters.contains(where: { $0.id == newCharacter.id})}
                state.characters += newCharacters
                let favoriteIDs = state.favoriteIDs

                state.characters.sort {
                    if favoriteIDs.contains($0.id) != favoriteIDs.contains($1.id) {
                        return favoriteIDs.contains($0.id)
                    }
                    return $0.id < $1.id
                }
                state.canLoadMore = response.info.next != nil
                return .none
                
                // error
            case let .characterResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
                
                // pagination
            case .loadNextPage:
                guard !state.isLoading, state.canLoadMore else {
                    return .none
                }
                state.isLoading = true
                state.page += 1
                
                return .run {
                    [page = state.page,  search = state.searchText] send in
                    do {
                        let response = try await apiClient.fetchCharacters(page, search)
                        await send(.characterResponse(.success(response)))
                    } catch let error as APIError {
                        await send(.characterResponse(.failure(error)))
                    } catch {
                        await send(.characterResponse(.failure(.invalidResponse)))
                    }
                }
                // refresh
            case .refresh:
                state.page = 1
                state.characters = []
                state.canLoadMore = true
                
                return .send(.onAppear)
                // search
            case let .searchChanged(text):
                state.searchText = text
                state.page = 1
                state.characters = []
                state.isLoading = true
                
                return .run { send in
                    try await Task.sleep(for: .milliseconds(300))
                    do {
                        let response = try await apiClient.fetchCharacters(1, text)
                        await send(.characterResponse(.success(response)))
                    } catch let error as APIError {
                        await send(.characterResponse(.failure(error)))
                    } catch {
                        await send(.characterResponse(.failure(.invalidResponse)))
                    }
                }
                // toogle favorite add and delete
            case let .toggleFavorite(id):
                if state.favoriteIDs.contains(id){
                    state.favoriteIDs.remove(id)
                } else {
                    state.favoriteIDs.insert(id)
                }
                let favoriteIDs = state.favoriteIDs

                state.characters.sort {
                    if favoriteIDs.contains($0.id) != favoriteIDs.contains($1.id) {
                        return favoriteIDs.contains($0.id)
                    }
                    return $0.id < $1.id
                }
                return .none
                
                // set favorites
            case let .setFavorites(ids):
                state.favoriteIDs = ids
                return .none
            }
        }
    }
}

