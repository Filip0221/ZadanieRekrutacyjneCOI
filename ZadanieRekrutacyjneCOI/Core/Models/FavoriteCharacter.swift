//
//  FavoriteCharacter.swift
//  ZadanieRekrutacyjneCOI
//
//  Created by Filip Skup on 17/04/2026.
//

import Foundation
import SwiftData

@Model
final class FavoriteCharacter{
    @Attribute(.unique) var id: Int
    
    init(id: Int) {
        self.id = id
    }
}
