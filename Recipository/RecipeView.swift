//
//  RecipeView.swift
//  Recipository
//

import SwiftUI

struct RecipeView: View {
    let meal: Meal
    var onBack: () -> Void

    @State private var detail: MealDetail? = nil
    @State private var currentStepIndex: Int = 0
    @State private var isLoading = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Spacer().frame(height: 0)

            // Back button
            Button { onBack() } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .font(.subheadline)
            }
            .buttonStyle(.plain)

            // Top row: Step bar + Timer
            HStack(alignment: .top, spacing: 12) {
                RecipeStepView(
                    detail: detail,
                    currentStepIndex: $currentStepIndex,
                    isLoading: isLoading
                )
                .frame(maxWidth: .infinity)
                .frame(height: 80)
                .background(Color(red: 0.588, green: 0.482, blue: 0.714).opacity(0.15))
                .glassBackgroundEffect()

                TimerView()
                    .frame(width: 100, height: 80)
                    .background(Color(red: 0.588, green: 0.482, blue: 0.714).opacity(0.15))
                    .glassBackgroundEffect()
            }

            // Action buttons row
            HStack(spacing: 10) {
                IngredientsAndEquipmentView()
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(Color(red: 0.588, green: 0.482, blue: 0.714).opacity(0.15))
                    .glassBackgroundEffect()

                MethodView()
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(Color(red: 0.588, green: 0.482, blue: 0.714).opacity(0.15))
                    .glassBackgroundEffect()

                FinishedProductView()
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(Color(red: 0.588, green: 0.482, blue: 0.714).opacity(0.15))
                    .glassBackgroundEffect()
            }
        }
        .padding()
        .task {
            isLoading = true
            detail = try? await MealService.fetchDetail(id: meal.idMeal)
            currentStepIndex = 0
            isLoading = false
        }
    }
}
