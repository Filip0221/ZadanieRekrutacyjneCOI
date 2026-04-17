//
//  APIClient.swift
//  ZadanieRekrutacyjneCOI
//
//  Created by Filip Skup on 13/04/2026.
//
import Foundation
import ComposableArchitecture

struct APIClient {
    var fetchCharacters: @Sendable (_ page: Int, _ name: String?) async throws -> CharacterResponseDTO
    var fetchEpisode: @Sendable (_ id: Int) async throws -> EpisodeDTO
    var fetchEpisodes: @Sendable (_ ids: [Int]) async throws -> [EpisodeDTO]
    var fetchCharactersByIds: @Sendable (_ ids: [Int]) async throws -> [CharacterDTO]
}

extension APIClient {
    static let live = Self(
        fetchCharacters: { page, name in
            var components = URLComponents(string: "https://rickandmortyapi.com/api/character")!
            var queryItems: [URLQueryItem] = [
                URLQueryItem(name: "page", value: String(page))
            ]
            
            if let name, !name.isEmpty{
                queryItems.append(URLQueryItem(name: "name", value: name))
            }
            
            components.queryItems = queryItems
            
            guard let url = components.url else {
                throw APIError.invalidURL
            }
            let (data, response) = try await URLSession.shared.data(from: url)
            try validate(response: response)
            do {
                return try JSONDecoder().decode(CharacterResponseDTO.self, from: data)
            } catch {
                throw APIError.decodingFailed
            }
            
        },
        fetchEpisode: { id in
            let urlString = "https://rickandmortyapi.com/api/episode/\(id)"
            guard let url = URL(string: urlString) else {
                throw APIError.invalidURL
            }
            let (data, response) = try await URLSession.shared.data(from: url)
            try validate(response: response)
            do {
                return try JSONDecoder().decode(EpisodeDTO.self, from: data)
            } catch {
                throw APIError.decodingFailed
            }
        },
        fetchEpisodes: { ids in
            guard !ids.isEmpty else { return [] }
            let idString = ids.map(String.init).joined(separator: ",")
            let urlString = "https://rickandmortyapi.com/api/episode/\(idString)"
            guard let url = URL(string: urlString) else {
                throw APIError.invalidURL
            }
            let (data, response) = try await URLSession.shared.data(from: url)
            try validate(response: response)
            do {
                if ids.count == 1 {
                    let episode = try JSONDecoder().decode(EpisodeDTO.self, from: data)
                    return [episode]
                } else {
                    return try JSONDecoder().decode([EpisodeDTO].self, from: data)
                }
            } catch {
                throw APIError.decodingFailed
            }
        },
        fetchCharactersByIds: {ids in
            guard !ids.isEmpty else {
                return[]
            }
            let idString = ids.map(String.init).joined(separator: ",")
            let urlString = "https://rickandmortyapi.com/api/character/\(idString)"
            
            guard let url = URL(string: urlString) else {
                throw APIError.invalidURL
            }
            
            let (data, response) = try await URLSession.shared.data(from: url)
            try validate(response: response)
            
            do {
                if ids.count == 1 {
                    let character = try JSONDecoder().decode(CharacterDTO.self, from: data)
                    return [character]
                } else {
                    return try JSONDecoder().decode([CharacterDTO].self, from: data)
                }
            } catch {
                throw APIError.decodingFailed
            }
        }
    )
}

extension APIClient: DependencyKey{
    static let liveValue = APIClient.live
}
extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}
nonisolated private func validate(response: URLResponse) throws {
    guard let httpResponse = response as? HTTPURLResponse else {
        throw APIError.invalidResponse
    }
    
    switch httpResponse.statusCode {
    case 200...299:
        return
    case 404:
        throw APIError.notFound
    default:
        throw APIError.serverError(statusCode: httpResponse.statusCode)
    }
}
