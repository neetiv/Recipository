//
//  ContentView.swift
//  Recipository
//
//  Created by Neeti Vaidya on 4/18/26.
//

import SwiftUI

struct ContentView: View {
    @State private var currentPage: Page = .voiceCommands
    /// Meal chosen in the list; used to open `RecipeView`, which fetches full detail once by id.
    @State private var selectedRecipe: Meal?

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
            RecipeListView(onSelectRecipe: { meal in
                selectedRecipe = meal
                currentPage = .recipe
            })
        case .ingredientsAndEquipment:
            standaloneIngredientsPlaceholder
        case .rating:
            RatingView()
        case .recipe:
            if let meal = selectedRecipe {
                RecipeView(summaryMeal: meal)
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

    private var standaloneIngredientsPlaceholder: some View {
        VStack(spacing: 16) {
            Image(systemName: "fork.knife")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("Ingredients and equipment")
                .font(.title2.weight(.semibold))
            Text("Open a recipe from the list, then use the Ingredients tab inside the recipe.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Ingredients are available inside an open recipe.")
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
