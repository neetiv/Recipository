//
//  RecipeView.swift
//  Recipository
//
//  Created by Neeti Vaidya on 4/18/26.
//

import SwiftUI

struct RecipeView: View {
    var onBack: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Spacer()
                .frame(height: 0)
            // Back button
            Button {
                onBack()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .font(.subheadline)
            }
            .buttonStyle(.plain)

            // Top row: Step bar + Timer
            HStack(alignment: .top, spacing: 12) {
                // Step bar — wide
                RecipeStepView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .background(Color(red: 0.588, green: 0.482, blue: 0.714).opacity(0.15))
                    .glassBackgroundEffect()

                // Timer — small
                TimerView()
                    .frame(width: 100, height: 80)
                    .background(Color(red: 0.588, green: 0.482, blue: 0.714).opacity(0.15))
                    .glassBackgroundEffect()
            }

            // Action buttons row
            HStack(spacing: 10) {
                IngredientsAndEquipmentView()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(red: 0.588, green: 0.482, blue: 0.714).opacity(0.15))
                    .glassBackgroundEffect()

                MethodView()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(red: 0.588, green: 0.482, blue: 0.714).opacity(0.15))
                    .glassBackgroundEffect()

                FinishedProductView()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(red: 0.588, green: 0.482, blue: 0.714).opacity(0.15))
                    .glassBackgroundEffect()
            }
        }
        .padding()
    }
}
