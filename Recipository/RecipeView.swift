//
//  RecipeView.swift
//  Recipository
//
//  Created by Neeti Vaidya on 4/18/26.
//

import SwiftUI

struct RecipeView: View {
    /// Summary meal from the list (id + title + thumb). Full detail is loaded once into `detailMeal`.
    let summaryMeal: Meal

    @State private var detailMeal: Meal?
    @State private var isLoading = false
    @State private var errorMessage: String?

    @State private var selectedTab: Tab = .steps

    enum Tab: String, CaseIterable {
        case steps = "Steps"
        case ingredients = "Ingredients"
        case timer = "Timer"
        case rating = "Rating"

        var icon: String {
            switch self {
            case .steps: return "list.number"
            case .ingredients: return "fork.knife"
            case .timer: return "timer"
            case .rating: return "star"
            }
        }

        var accessibilityHint: String {
            switch self {
            case .steps: return "Shows cooking steps for this recipe."
            case .ingredients: return "Shows ingredients and suggested equipment."
            case .timer: return "Opens the countdown timer."
            case .rating: return "Rate this recipe."
            }
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            Group {
                switch selectedTab {
                case .steps:
                    recipeDetailTab { meal in
                        RecipeStepView(meal: meal)
                    }
                case .ingredients:
                    recipeDetailTab { meal in
                        IngredientsAndEquipmentView(meal: meal)
                    }
                case .timer:
                    TimerView()
                case .rating:
                    RatingView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .glassBackgroundEffect()

            HStack(spacing: 12) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: tab.icon)
                                .font(.title3)
                            Text(tab.rawValue)
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                    .opacity(selectedTab == tab ? 1.0 : 0.5)
                    .accessibilityLabel(tab.rawValue)
                    .accessibilityHint(tab.accessibilityHint)
                    .accessibilityInputLabels([tab.rawValue])
                    .accessibilityAddTraits(selectedTab == tab ? [.isButton, .isSelected] : .isButton)
                }
            }
            .padding(.horizontal)
        }
        .padding()
        .task(id: summaryMeal.idMeal) {
            await loadDetailIfNeeded()
        }
    }

    @ViewBuilder
    private func recipeDetailTab<Content: View>(
        @ViewBuilder content: @escaping (Meal) -> Content
    ) -> some View {
        if isLoading, detailMeal == nil {
            ProgressView("Loading recipe…")
                .accessibilityLabel("Loading recipe")
                .accessibilityHint("Recipe details are being downloaded.")
        } else if let errorMessage, detailMeal == nil {
            Text(errorMessage)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .accessibilityLabel(errorMessage)
        } else if let meal = detailMeal {
            content(meal)
        } else {
            ProgressView("Loading recipe…")
                .accessibilityLabel("Loading recipe")
        }
    }

    private func loadDetailIfNeeded() async {
        guard detailMeal?.idMeal != summaryMeal.idMeal else { return }
        isLoading = true
        errorMessage = nil
        detailMeal = nil
        do {
            detailMeal = try await MealService.fetchMealDetail(id: summaryMeal.idMeal)
        } catch {
            errorMessage = "Could not load this recipe. Check your connection and try again."
        }
        isLoading = false
    }
}

#Preview {
    RecipeView(summaryMeal: .preview)
}
