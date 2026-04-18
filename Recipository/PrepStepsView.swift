//
//  PrepStepsView.swift
//  Recipository
//

import SwiftUI

struct PrepStepsView: View {
    let meal: Meal
    var onBack: () -> Void
    var onContinue: () -> Void

    @State private var detail: MealDetail?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var checkedItems: Set<String> = []

    private var checklistItems: [PrepChecklistItem] {
        guard let detail else { return [] }
        return PrepChecklistBuilder.build(from: detail)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header

            if isLoading {
                ProgressView("Scanning recipe for prep steps…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                content
            }
        }
        .padding()
        .task(id: meal.idMeal) {
            await loadDetail()
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Label("Back", systemImage: "chevron.left")
                    .font(.subheadline)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text("Prep Steps")
                    .font(.title2.weight(.semibold))
                Text("Complete these prep tasks before starting recipe steps.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: onContinue) {
                Label("Start Recipe", systemImage: "arrow.right.circle.fill")
                    .font(.headline)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if checklistItems.isEmpty {
                    Text("No specific prep tasks were detected. You can start the recipe.")
                        .foregroundStyle(.secondary)
                        .padding(.top, 8)
                } else {
                    ForEach(checklistItems) { item in
                        Button {
                            toggle(item.id)
                        } label: {
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: checkedItems.contains(item.id) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(checkedItems.contains(item.id) ? .green : .secondary)
                                Text(item.title)
                                    .foregroundStyle(.primary)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(item.title)
                        .accessibilityHint("Double tap to mark this prep task complete.")

                        if item.id != checklistItems.last?.id {
                            Divider()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func toggle(_ id: String) {
        if checkedItems.contains(id) {
            checkedItems.remove(id)
        } else {
            checkedItems.insert(id)
        }
    }

    private func loadDetail() async {
        isLoading = true
        errorMessage = nil
        do {
            detail = try await MealService.fetchDetail(id: meal.idMeal)
        } catch {
            detail = nil
            errorMessage = "Could not load recipe details for prep step detection."
        }
        isLoading = false
    }
}

private struct PrepChecklistItem: Identifiable {
    let id: String
    let title: String
}

private enum PrepChecklistBuilder {
    private static let allItems: [(title: String, keywords: [String])] = [
        ("Preheat oven", ["preheat"]),
        ("Position oven racks", ["rack"]),
        ("Grease, flour, or line pans", ["grease", "flour the pan", "parchment", "line a", "line the pan"]),
        ("Chill bowls or beaters", ["chill bowl", "chill bowls", "beater"]),
        ("Bring butter to room temperature", ["butter", "softened", "room temperature"]),
        ("Bring eggs to room temperature", ["eggs room temperature", "egg room temperature"]),
        ("Bring cream cheese to room temperature", ["cream cheese", "room temperature"]),
        ("Melt butter", ["melt butter"]),
        ("Warm milk or cream", ["warm milk", "warm cream", "lukewarm milk"]),
        ("Sift flour, cocoa, or powdered sugar", ["sift flour", "sift cocoa", "powdered sugar", "sift"]),
        ("Measure and pre-mix dry ingredients", ["dry ingredients", "combine flour", "mix flour"]),
        ("Zest citrus", ["zest", "zested"]),
        ("Juice citrus", ["juice", "juiced", "lemon juice", "orange juice", "lime juice"]),
        ("Chop nuts", ["chopped nuts", "chop nuts"]),
        ("Chop chocolate", ["chop chocolate", "chopped chocolate"]),
        ("Toast nuts or coconut", ["toast nuts", "toasted coconut", "toast coconut"]),
        ("Pit and slice fruit", ["pitted", "pit", "slice fruit", "sliced fruit"]),
        ("Bloom gelatin in cold water", ["bloom gelatin", "gelatin"]),
        ("Dissolve and proof yeast", ["proof yeast", "dissolve yeast", "yeast"]),
        ("Soak dried fruit in liquid", ["soak dried", "soaked raisins", "soak fruit"]),
        ("Make a double boiler setup", ["double boiler", "bain marie"]),
        ("Mise en place (measure everything first)", ["measure all ingredients", "mise en place", "have all ingredients ready"]),
    ]

    static func build(from detail: MealDetail) -> [PrepChecklistItem] {
        let text = searchableText(detail).lowercased()
        var items: [PrepChecklistItem] = []
        for rule in allItems {
            if rule.keywords.contains(where: { text.contains($0) }) {
                items.append(PrepChecklistItem(id: rule.title, title: rule.title))
            }
        }
        return items
    }

    private static func searchableText(_ detail: MealDetail) -> String {
        let ingredientText = detail.ingredients
            .map { "\($0.name) \($0.measure)" }
            .joined(separator: " ")
        return detail.strInstructions + " " + ingredientText
    }
}

#Preview {
    PrepStepsView(
        meal: Meal(idMeal: "52767", strMeal: "Bakewell tart", strMealThumb: ""),
        onBack: {},
        onContinue: {}
    )
}
