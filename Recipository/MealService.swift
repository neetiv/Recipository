//
//  MealService.swift
//  Recipository
//
//  Created by Neeti Vaidya on 4/18/26.
//

import Foundation

struct Meal: Identifiable, Decodable {
    let idMeal: String
    let strMeal: String
    let strMealThumb: String
    let strCategory: String?
    let strArea: String?
    let strInstructions: String?
    let ingredientPairs: [(ingredient: String, measure: String)]

    var id: String { idMeal }

    private enum BaseKeys: String, CodingKey {
        case idMeal, strMeal, strMealThumb, strCategory, strArea, strInstructions
    }

    private struct DynamicCodingKey: CodingKey {
        var stringValue: String
        init?(stringValue: String) { self.stringValue = stringValue }
        var intValue: Int? { nil }
        init?(intValue: Int) { nil }
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: BaseKeys.self)
        idMeal = try c.decode(String.self, forKey: .idMeal)
        strMeal = try c.decode(String.self, forKey: .strMeal)
        strMealThumb = try c.decode(String.self, forKey: .strMealThumb)
        strCategory = try c.decodeIfPresent(String.self, forKey: .strCategory)
        strArea = try c.decodeIfPresent(String.self, forKey: .strArea)
        strInstructions = try c.decodeIfPresent(String.self, forKey: .strInstructions)

        let dyn = try decoder.container(keyedBy: DynamicCodingKey.self)
        var pairs: [(String, String)] = []
        for i in 1...20 {
            guard let ik = DynamicCodingKey(stringValue: "strIngredient\(i)"),
                  let mk = DynamicCodingKey(stringValue: "strMeasure\(i)") else { continue }
            let ing = (try dyn.decodeIfPresent(String.self, forKey: ik))?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let meas = (try dyn.decodeIfPresent(String.self, forKey: mk))?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !ing.isEmpty {
                pairs.append((ing, meas))
            }
        }
        ingredientPairs = pairs
    }

    /// Memberwise initializer for previews and tests (not used for API decoding).
    init(
        idMeal: String,
        strMeal: String,
        strMealThumb: String,
        strCategory: String? = nil,
        strArea: String? = nil,
        strInstructions: String? = nil,
        ingredientPairs: [(String, String)] = []
    ) {
        self.idMeal = idMeal
        self.strMeal = strMeal
        self.strMealThumb = strMealThumb
        self.strCategory = strCategory
        self.strArea = strArea
        self.strInstructions = strInstructions
        self.ingredientPairs = ingredientPairs
    }
}

struct MealResponse: Decodable {
    let meals: [Meal]?
}

enum MealServiceError: Error {
    case mealNotFound
}

struct MealService {
    static func fetchDesserts() async throws -> [Meal] {
        let url = URL(string: "https://www.themealdb.com/api/json/v1/1/filter.php?c=Dessert")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(MealResponse.self, from: data)
        return (response.meals ?? []).sorted { $0.strMeal < $1.strMeal }
    }

    /// Full recipe detail (ingredients, instructions, category, …) for a meal id from the list API.
    static func fetchMealDetail(id: String) async throws -> Meal {
        let url = URL(string: "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(id)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(MealResponse.self, from: data)
        guard let meal = response.meals?.first else {
            throw MealServiceError.mealNotFound
        }
        return meal
    }
}

extension Meal {
    static let preview: Meal = Meal(
        idMeal: "52767",
        strMeal: "Bakewell tart",
        strMealThumb: "https://www.themealdb.com/images/media/meals/wyrqqq1468233628.jpg",
        strCategory: "Dessert",
        strArea: "British",
        strInstructions: "Sample instructions.",
        ingredientPairs: [
            ("plain flour", "200g"),
            ("butter", "4 oz, softened"),
            ("caster sugar", "1/2 cup"),
            ("egg", "2 large"),
            ("raspberry jam", "3 tbsp"),
        ]
    )
}
