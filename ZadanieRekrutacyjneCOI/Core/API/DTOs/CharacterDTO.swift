//
//  CharacterDTO.swift
//  ZadanieRekrutacyjneCOI
//
//  Created by Filip Skup on 13/04/2026.
//

import Foundation

struct CharacterDTO: Decodable, Equatable, Identifiable {
    let id: Int
    let name: String
    let status: String
    let gender: String
    let origin: CharacterLocationDTO
    let location: CharacterLocationDTO
    let image: String
    let episode: [String]
    
}
struct CharacterLocationDTO: Decodable, Equatable {
    let name: String
}
