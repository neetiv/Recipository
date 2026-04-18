//
//  RecipeStepView.swift
//  Recipository
//

import SwiftUI

struct RecipeStepView: View {
    let detail: MealDetail?
    @Binding var currentStepIndex: Int
    let isLoading: Bool

    private var steps: [String] { detail?.steps ?? [] }
    private var hasPrev: Bool { currentStepIndex > 0 }
    private var hasNext: Bool { currentStepIndex < steps.count - 1 }

    var body: some View {
        HStack(spacing: 8) {

            // Prev button
            Button {
                if hasPrev { currentStepIndex -= 1 }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.caption)
            }
            .buttonStyle(.plain)
            .opacity(hasPrev ? 1 : 0.25)
            .disabled(!hasPrev)

            // Step content
            VStack(alignment: .leading, spacing: 2) {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if steps.isEmpty {
                    Text("No steps available.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    Text("Step \(currentStepIndex + 1) of \(steps.count)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Text(steps[currentStepIndex])
                        .font(.body)                          // start bigger than .caption
                        .minimumScaleFactor(0.3)              // allow shrinking if needed
                        .lineLimit(nil)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.horizontal, 4)

            // Next button
            Button {
                if hasNext { currentStepIndex += 1 }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.caption)
            }
            .buttonStyle(.plain)
            .opacity(hasNext ? 1 : 0.25)
            .disabled(!hasNext)
        }
        .padding(.horizontal, 10)
    }
}
