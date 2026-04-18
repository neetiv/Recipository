//
//  RecipeStepView.swift
//  Recipository
//
//  Created by Neeti Vaidya on 4/18/26.
//

import SwiftUI

struct RecipeStepView: View {
    let meal: Meal

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(meal.strMeal)
                    .font(.title2.weight(.semibold))

                if let instructions = meal.strInstructions?.trimmingCharacters(in: .whitespacesAndNewlines),
                   !instructions.isEmpty {
                    Text(instructions.replacingOccurrences(of: "\r\n", with: "\n"))
                        .font(.body)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Cooking steps will appear here once this view is built out.")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Recipe steps for \(meal.strMeal)")
    }
}

#Preview {
    RecipeStepView(meal: .preview)
}
