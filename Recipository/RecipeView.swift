//
//  RecipeView.swift
//  Recipository
//
//  Created by Neeti Vaidya on 4/18/26.
//

import SwiftUI

struct RecipeView: View {
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
    }

    var body: some View {
        VStack(spacing: 16) {
            // Content bubble — swaps based on selected tab
            Group {
                switch selectedTab {
                case .steps:
                    RecipeStepView()
                case .ingredients:
                    IngredientsAndEquipmentView()
                case .timer:
                    TimerView()
                case .rating:
                    RatingView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .glassBackgroundEffect()

            // Tab bar
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
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }
}
