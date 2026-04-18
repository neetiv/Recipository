//
//  RecipeListView.swift
//  Recipository
//
//  Created by Neeti Vaidya on 4/18/26.
//

import SwiftUI

struct RecipeListView: View {
    var onSelectRecipe: (Meal) -> Void

    @State private var meals: [Meal] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose a Recipe")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)

            if isLoading {
                Spacer()
                ProgressView("Loading desserts...")
                    .frame(maxWidth: .infinity)
                Spacer()
            } else if let errorMessage {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    Text(errorMessage)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 12)], spacing: 12) {
                        ForEach(meals) { meal in
                            Button {
                                onSelectRecipe(meal)
                            } label: {
                                recipeCard(meal: meal)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
        .task {
            await loadMeals()
        }
    }

    private func recipeCard(meal: Meal) -> some View {
        VStack(spacing: 0) {
            AsyncImage(url: URL(string: meal.strMealThumb)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .foregroundStyle(.quaternary)
                    .overlay {
                        ProgressView()
                    }
            }
            .frame(height: 100)
            .clipped()

            Text(meal.strMeal)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .padding(10)
                .frame(maxWidth: .infinity)
        }
        .background(Color(red: 0.588, green: 0.482, blue: 0.714).opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .hoverEffect()
    }

    private func loadMeals() async {
        do {
            meals = try await MealService.fetchDesserts()
            isLoading = false
        } catch {
            errorMessage = "Could not load recipes. Check your connection."
            isLoading = false
        }
    }
}
