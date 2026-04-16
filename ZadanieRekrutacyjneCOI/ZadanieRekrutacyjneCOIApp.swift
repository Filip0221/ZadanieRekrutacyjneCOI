//
//  ZadanieRekrutacyjneCOIApp.swift
//  ZadanieRekrutacyjneCOI
//
//  Created by Filip Skup on 13/04/2026.
//

import SwiftUI
import ComposableArchitecture

@main
struct ZadanieRekrutacyjneCOIApp: App {
    var body: some Scene {
        WindowGroup {
            CharactersListView(
                store: Store(
                    initialState: CharactersListFeature.State()){
                        CharactersListFeature()
                    }
                
            )
        }
    }
}
