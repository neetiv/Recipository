//
//  MealService.swift
//  Recipository
//

import Foundation

struct Meal: Codable, Identifiable {
    let idMeal: String
    let strMeal: String
    let strMealThumb: String

    var id: String { idMeal }
}

struct MealResponse: Codable {
    let meals: [Meal]
}

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
    let meals: [MealDetail]
}

struct MealService {
    static func fetchDesserts() async throws -> [Meal] {
        let url = URL(string: "https://www.themealdb.com/api/json/v1/1/filter.php?c=Dessert")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(MealResponse.self, from: data)
        return response.meals.sorted { $0.strMeal < $1.strMeal }
    }

    static func fetchDetail(id: String) async throws -> MealDetail {
        let url = URL(string: "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(id)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(MealDetailResponse.self, from: data)
        guard let detail = response.meals.first else {
            throw URLError(.badServerResponse)
        }
        return detail
    }
}
