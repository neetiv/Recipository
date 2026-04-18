//
//  ContentView.swift
//  Recipository
//

import SwiftUI

struct ContentView: View {
    @State private var currentPage: Page = .voiceCommands
    @State private var selectedMeal: Meal? = nil

    enum Page {
        case voiceCommands, recipeList, recipe
    }

    var body: some View {
        switch currentPage {
        case .voiceCommands:
            VoiceCommandsView(onDismiss: { currentPage = .recipeList })

        case .recipeList:
            RecipeListView { meal in
                selectedMeal = meal
                currentPage = .recipe
            }

        case .recipe:
            if let meal = selectedMeal {
                RecipeView(meal: meal, onBack: {
                    selectedMeal = nil
                    currentPage = .recipeList
                })
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
