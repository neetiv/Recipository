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

    private var currentStep: String {
        detail?.steps[safe: currentStepIndex] ?? ""
    }

    var body: some View {
        ScrollView {
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

                // Top row: Step bar + Timer side by side
                HStack(alignment: .top, spacing: 12) {
                    RecipeStepView(
                        detail: detail,
                        currentStepIndex: $currentStepIndex,
                        isLoading: isLoading
                    )
                    .frame(maxWidth: .infinity)
                    .padding(8)
                    .background(Color(red: 0.588, green: 0.482, blue: 0.714).opacity(0.15))
                    .glassBackgroundEffect()

                    if !isLoading,
                       let steps = detail?.steps,
                       steps.indices.contains(currentStepIndex) {
                        TimerView(stepString: steps[currentStepIndex])
                            .frame(width: 110)
                            .fixedSize(horizontal: true, vertical: false)
                            .background(Color(red: 0.588, green: 0.482, blue: 0.714).opacity(0.15))
                            .glassBackgroundEffect()
                    }
                }
                .frame(maxWidth: .infinity)

                // Method button — only shown when a culinary keyword is detected
                if !currentStep.isEmpty {
                    let keywords = ["whisk", "fold", "knead", "cream", "sift", "pipe", "separate", "temper"]
                    let needsMethod = keywords.contains { currentStep.lowercased().contains($0) }

                    if needsMethod {
                        MethodView(currentStep: currentStep)
                            .padding(.horizontal, 16).padding(.vertical, 10)
                            .background(Color(red: 0.588, green: 0.482, blue: 0.714).opacity(0.15))
                            .glassBackgroundEffect()
                    }
                }
            }
            .padding()
        }
        .task {
            isLoading = true
            detail = try? await MealService.fetchDetail(id: meal.idMeal)
            currentStepIndex = 0
            isLoading = false
        }
    }
}

// Safe array subscript
extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
