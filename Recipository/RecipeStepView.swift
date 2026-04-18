//
//  RecipeStepView.swift
//  Recipository
//

import SwiftUI

/// Shows one step at a time with prev/next (teammate UX) using the shared `Meal` model (no second fetch).
struct RecipeStepView: View {
    let meal: Meal
    @Binding var currentStepIndex: Int

    private var steps: [String] { meal.instructionSteps }

    private var hasPrev: Bool { currentStepIndex > 0 }
    private var hasNext: Bool { steps.count > 0 && currentStepIndex < steps.count - 1 }

    var body: some View {
        Group {
            if steps.isEmpty {
                scrollFallback
            } else {
                stepPager
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Recipe steps for \(meal.strMeal)")
    }

    private var scrollFallback: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(meal.strMeal)
                    .font(.title2.weight(.semibold))

                if let text = meal.strInstructions?.trimmingCharacters(in: .whitespacesAndNewlines),
                   !text.isEmpty {
                    Text(text.replacingOccurrences(of: "\r\n", with: "\n"))
                        .font(.body)
                        .foregroundStyle(.secondary)
                } else {
                    Text("No steps available.")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var stepPager: some View {
        HStack(spacing: 8) {
            Button {
                if hasPrev { currentStepIndex -= 1 }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.caption)
            }
            .buttonStyle(.plain)
            .opacity(hasPrev ? 1 : 0.25)
            .disabled(!hasPrev)
            .accessibilityLabel("Previous step")
            .accessibilityHint("Go to the previous instruction")

            VStack(alignment: .leading, spacing: 4) {
                Text("Step \(currentStepIndex + 1) of \(steps.count)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Text(steps[currentStepIndex])
                    .font(.body)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.horizontal, 4)

            Button {
                if hasNext { currentStepIndex += 1 }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.caption)
            }
            .buttonStyle(.plain)
            .opacity(hasNext ? 1 : 0.25)
            .disabled(!hasNext)
            .accessibilityLabel("Next step")
            .accessibilityHint("Go to the next instruction")
        }
        .padding(.horizontal, 6)
    }
}

#Preview {
    RecipeStepView(meal: .preview, currentStepIndex: .constant(0))
}
