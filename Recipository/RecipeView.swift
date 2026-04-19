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
    @State private var handCoach = CookingHandCoach()

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

                if handCoach.shouldShowHandTrackingSettingsHint {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "hand.raised.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .accessibilityHidden(true)
                        Text("Hand tracking is off. For motion coaching, enable Hand Tracking under Settings → Privacy & Security → Recipository.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.orange.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .accessibilityElement(children: .combine)
                }

                // Top row: Step bar + Timer side by side
                HStack(alignment: .top, spacing: 12) {
                    RecipeStepView(
                        detail: detail,
                        currentStepIndex: $currentStepIndex,
                        isLoading: isLoading,
                        handCoach: handCoach
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
        .task(id: meal.idMeal) {
            await handCoach.requestHandTrackingAuthorizationOnAppear()
            isLoading = true
            detail = try? await MealService.fetchDetail(id: meal.idMeal)
            currentStepIndex = 0
            isLoading = false
            syncHandCoachStep()
        }
        .onChange(of: detail?.idMeal) { _, _ in
            syncHandCoachStep()
        }
        .onChange(of: currentStepIndex) { _, _ in
            syncHandCoachStep()
        }
        .onDisappear {
            handCoach.stop()
        }
    }

    private func syncHandCoachStep() {
        guard let detail, !detail.steps.isEmpty, detail.steps.indices.contains(currentStepIndex) else { return }
        handCoach.update(stepText: detail.steps[currentStepIndex], stepIndex: currentStepIndex)
    }
}

// Safe array subscript
extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
