//
//  EpisodeDetails.swift
//  ZadanieRekrutacyjneCOI
//
//  Created by Filip Skup on 17/04/2026.
//
import ComposableArchitecture
import Foundation

@Reducer
struct EpisodeDetailsFeature{
    @ObservableState
    struct State: Equatable{
        var episodeID: Int
        var episode: EpisodeDTO?
        var isLoading = false
        var errorMessage: String? = nil
        var characters: [CharacterDTO] = []
    }
    
    enum Action: Equatable {
        case onAppear
        case episodeResponse(Result<EpisodeDTO, APIError>)
        case charactersResponse(Result<[CharacterDTO], APIError>)
    }
    @Dependency(\.apiClient) var apiClient

    var body: some Reducer<State, Action> {
        Reduce{ state, action in
            switch action {
                // firstload
            case .onAppear:
                state.isLoading = true
                state.errorMessage = nil
                let id = state.episodeID
                
                return .run{send in
                    do {
                        let episode = try await apiClient.fetchEpisode(id)
                        await send(.episodeResponse(.success(episode)))
                    } catch let error as APIError {
                        await send(.episodeResponse(.failure(error)))
                    } catch {
                        await send(.episodeResponse(.failure(.invalidResponse)))
                    }
                }
                // success
            case let .episodeResponse(.success(episode)):
                state.isLoading = false
                state.episode = episode
                let ids = episode.characters.compactMap {
                        $0.split(separator: "/").last.flatMap { Int($0) }
                    }
                return .run { send in
                        do {
                            let characters = try await apiClient.fetchCharactersByIds(ids)
                            await send(.charactersResponse(.success(characters)))
                        } catch {
                            let apiError = error as? APIError ?? .invalidResponse
                            await send(.charactersResponse(.failure(apiError)))
                        }
                    }
                // error
            case let .episodeResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
                // success characters
            case let .charactersResponse(.success(characters)):
                state.characters = characters
                return .none
                // error characters
            case let .charactersResponse(.failure(error)):
                state.errorMessage = error.localizedDescription
                return .none
            }
       
        }
    }
}
