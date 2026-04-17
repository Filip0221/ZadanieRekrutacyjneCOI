//
//  PageInfoDTO.swift
//  ZadanieRekrutacyjneCOI
//
//  Created by Filip Skup on 13/04/2026.
//

import Foundation

nonisolated struct PageInfoDTO: Decodable, Equatable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}
