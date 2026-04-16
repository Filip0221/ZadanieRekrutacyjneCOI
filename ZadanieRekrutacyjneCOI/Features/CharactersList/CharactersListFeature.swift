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
    }
    
    enum Action: Equatable {
        case onAppear
        case characterResponse(Result<CharacterResponseDTO, APIError>)
        case loadNextPage
        case refresh
        case searchChanged(String)
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
            }
        }
    }
}

