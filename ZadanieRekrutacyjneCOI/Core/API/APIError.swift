//
//  APIError.swift
//  ZadanieRekrutacyjneCOI
//
//  Created by Filip Skup on 13/04/2026.
//

import Foundation

enum APIError: Error, Equatable, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingFailed
    case notFound
    case serverError(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Nie udało się utworzyć poprawnego adresu URL."
        case .invalidResponse:
            return "Serwer zwrócił niepoprawną odpowiedź."
        case .decodingFailed:
            return "Nie udało się odczytać danych z serwera."
        case .notFound:
            return "Nie znaleziono danych."
        case let .serverError(statusCode):
            return "Błąd serwera. Kod: \(statusCode)."
        }
    }
}
