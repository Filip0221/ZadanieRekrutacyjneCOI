//
//  CharacterResponseDTO.swift
//  ZadanieRekrutacyjneCOI
//
//  Created by Filip Skup on 13/04/2026.
//

import Foundation

struct CharacterResponseDTO: Decodable, Equatable {
    let info: PageInfoDTO
    let results: [CharacterDTO]
}
