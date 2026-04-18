//
//  MealService.swift
//  Recipository
//
//  Created by Neeti Vaidya on 4/18/26.
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

struct MealService {
    static func fetchDesserts() async throws -> [Meal] {
        let url = URL(string: "https://www.themealdb.com/api/json/v1/1/filter.php?c=Dessert")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(MealResponse.self, from: data)
        return response.meals.sorted { $0.strMeal < $1.strMeal }
    }
}
