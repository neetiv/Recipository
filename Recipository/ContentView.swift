//
//  ContentView.swift
//  Recipository
//
//  Created by Neeti Vaidya on 4/18/26.
//

import SwiftUI

struct ContentView: View {
    @State private var currentPage: Page = .voiceCommands

    enum Page {
        case voiceCommands
        case ingredientsAndEquipment
        case rating
        case recipe
    }

    var body: some View {
        switch currentPage {
        case .voiceCommands:
            VoiceCommandsView(onDismiss: { currentPage = .recipe })
        case .ingredientsAndEquipment:
            IngredientsAndEquipmentView()
        case .rating:
            RatingView()
        case .recipe:
            RecipeView()
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
