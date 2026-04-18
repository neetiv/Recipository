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
        case recipeList
        case ingredientsAndEquipment
        case rating
        case recipe
    }

    var body: some View {
        switch currentPage {
        case .voiceCommands:
            VoiceCommandsView(onDismiss: { currentPage = .recipeList })
        case .recipeList:
            RecipeListView(onSelectRecipe: { _ in currentPage = .recipe })
        case .ingredientsAndEquipment:
            IngredientsAndEquipmentView()
        case .rating:
            RatingView()
        case .recipe:
            RecipeView(onBack: { currentPage = .recipeList })
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
