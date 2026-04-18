//
//  MealService.swift
//  Recipository
//

import Foundation

// MARK: - Meal (list + detail; TheMealDB lookup decodes into this type)

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

// MARK: - Detail model (used by RecipeView / RecipeStepView)

struct MealDetail: Codable {
    let idMeal: String
    let strMeal: String
    let strMealThumb: String
    let strInstructions: String

    let strIngredient1: String?;  let strMeasure1: String?
    let strIngredient2: String?;  let strMeasure2: String?
    let strIngredient3: String?;  let strMeasure3: String?
    let strIngredient4: String?;  let strMeasure4: String?
    let strIngredient5: String?;  let strMeasure5: String?
    let strIngredient6: String?;  let strMeasure6: String?
    let strIngredient7: String?;  let strMeasure7: String?
    let strIngredient8: String?;  let strMeasure8: String?
    let strIngredient9: String?;  let strMeasure9: String?
    let strIngredient10: String?; let strMeasure10: String?
    let strIngredient11: String?; let strMeasure11: String?
    let strIngredient12: String?; let strMeasure12: String?
    let strIngredient13: String?; let strMeasure13: String?
    let strIngredient14: String?; let strMeasure14: String?
    let strIngredient15: String?; let strMeasure15: String?
    let strIngredient16: String?; let strMeasure16: String?
    let strIngredient17: String?; let strMeasure17: String?
    let strIngredient18: String?; let strMeasure18: String?
    let strIngredient19: String?; let strMeasure19: String?
    let strIngredient20: String?; let strMeasure20: String?

    var ingredients: [(name: String, measure: String)] {
        let pairs: [(String?, String?)] = [
            (strIngredient1, strMeasure1), (strIngredient2, strMeasure2),
            (strIngredient3, strMeasure3), (strIngredient4, strMeasure4),
            (strIngredient5, strMeasure5), (strIngredient6, strMeasure6),
            (strIngredient7, strMeasure7), (strIngredient8, strMeasure8),
            (strIngredient9, strMeasure9), (strIngredient10, strMeasure10),
            (strIngredient11, strMeasure11), (strIngredient12, strMeasure12),
            (strIngredient13, strMeasure13), (strIngredient14, strMeasure14),
            (strIngredient15, strMeasure15), (strIngredient16, strMeasure16),
            (strIngredient17, strMeasure17), (strIngredient18, strMeasure18),
            (strIngredient19, strMeasure19), (strIngredient20, strMeasure20),
        ]
        return pairs.compactMap { name, measure in
            guard let name, !name.trimmingCharacters(in: .whitespaces).isEmpty else { return nil }
            return (name, measure ?? "")
        }
    }

    var steps: [String] {
        strInstructions
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }
}

struct MealDetailResponse: Codable {
    let meals: [MealDetail]?
}

// MARK: - Service

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

    static func fetchDetail(id: String) async throws -> MealDetail {
        let url = URL(string: "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(id)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(MealDetailResponse.self, from: data)
        guard let detail = response.meals?.first else {
            throw URLError(.badServerResponse)
        }
        return detail
    }
}

extension Meal {
    /// Instruction lines for step-by-step UI (same splitting rules as `MealDetail.steps`).
    var instructionSteps: [String] {
        guard let strInstructions else { return [] }
        return strInstructions
            .replacingOccurrences(of: "\r\n", with: "\n")
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

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
