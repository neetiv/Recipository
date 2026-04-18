//
//  ContentView.swift
//  Recipository
//

import SwiftUI

struct ContentView: View {
    @State private var currentPage: Page = .voiceCommands
    /// Meal chosen in the list; passed into `RecipeView`, which loads full detail once by id.
    @State private var selectedMeal: Meal?

    enum Page {
        case voiceCommands
        case recipeList
        case recipe
    }

    var body: some View {
        switch currentPage {
        case .voiceCommands:
            VoiceCommandsView(onDismiss: { currentPage = .recipeList })

        case .recipeList:
            RecipeListView(onSelectRecipe: { meal in
                selectedMeal = meal
                currentPage = .recipe
            })

        case .recipe:
            if let meal = selectedMeal {
                RecipeView(summaryMeal: meal, onBack: {
                    selectedMeal = nil
                    currentPage = .recipeList
                })
            } else {
                Text("No recipe selected.")
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("No recipe selected")
                    .onAppear {
                        currentPage = .recipeList
                    }
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
