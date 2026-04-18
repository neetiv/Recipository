//
//  ContentView.swift
//  Recipository
//

import SwiftUI

struct ContentView: View {
    @State private var currentPage: Page = .voiceCommands
    @State private var selectedMeal: Meal?

    enum Page {
        case voiceCommands, recipeList, ingredientsAndEquipment, recipe
    }

    var body: some View {
        switch currentPage {
        case .voiceCommands:
            VoiceCommandsView(onDismiss: { currentPage = .recipeList })

        case .recipeList:
            RecipeListView { meal in
                selectedMeal = meal
                currentPage = .ingredientsAndEquipment
            }

        case .ingredientsAndEquipment:
            if let meal = selectedMeal {
                IngredientsAndEquipmentView(
                    meal: meal,
                    onBack: {
                        selectedMeal = nil
                        currentPage = .recipeList
                    },
                    onStartRecipe: {
                        currentPage = .recipe
                    }
                )
            }

        case .recipe:
            if let meal = selectedMeal {
                RecipeView(meal: meal, onBack: {
                    currentPage = .ingredientsAndEquipment
                })
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}

