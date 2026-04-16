//
//  CharacterDetailsFeature.swift
//  ZadanieRekrutacyjneCOI
//
//  Created by Filip Skup on 16/04/2026.
//
import ComposableArchitecture
import Foundation

@Reducer
struct CharacterDetailsFeature{
    @ObservableState
    struct State: Equatable{
        var character: CharacterDTO
        var episodes: [EpisodeDTO] = []
        var isLoading = false
        var errorMessage: String? = nil
    }
    
    enum Action: Equatable {
        case onAppear
        case episodesResponse(Result<[EpisodeDTO], APIError>)
    }
    @Dependency(\.apiClient) var apiClient
    
    var body: some Reducer<State, Action> {
        Reduce{ state, action in
            switch action {
                // first load
            case .onAppear:
                state .isLoading = true
                state.errorMessage = nil
                
                let ids = state.character.episode.compactMap{ urlString in
                    urlString
                        .split(separator: "/")
                        .last
                        .flatMap{ Int($0)}
                }
                return .run{send in
                    do {
                        let episodes = try await apiClient.fetchEpisodes(ids)
                        await send(.episodesResponse(.success(episodes)))
                    }catch let error as APIError {
                        await send(.episodesResponse(.failure(error)))
                    } catch {
                        await send(.episodesResponse(.failure(.invalidResponse)))
                    }
                }
                // success
            case let .episodesResponse(.success(episodes)):
                state.isLoading = false
                state.episodes = episodes
                return .none
                //error
            case let .episodesResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
            }}
            

    }
}
