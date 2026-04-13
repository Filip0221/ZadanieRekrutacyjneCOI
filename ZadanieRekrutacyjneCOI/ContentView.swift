//
//  ContentView.swift
//  ZadanieRekrutacyjneCOI
//
//  Created by Filip Skup on 13/04/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var characters: [CharacterDTO] = []
    @State private var error: String?

    var body: some View {
        NavigationStack {
            List(characters) { character in
                Text(character.name)
            }
            .navigationTitle("Characters")
            .task {
                await load()
            }
        }
    }

    func load() async {
        print("LOAD START")

        do {
            let response = try await APIClient.live.fetchCharacters(1, nil as String?)
            print("DATA:", response.results.count)
            characters = response.results
        } catch {
            print("ERROR:", error)
        }
    }
}
