//
//  IngredientsAndEquipmentView.swift
//  Recipository
//

import SwiftUI

/// Shows after choosing a recipe from the list. Fetches full detail locally so it works with the shared `Meal` list model.
struct IngredientsAndEquipmentView: View {
    let meal: Meal
    var onBack: (() -> Void)?
    var onStartRecipe: () -> Void

    @State private var detail: MealDetail?
    @State private var isLoading = false
    @State private var loadError: String?

    @State private var measurementMode: MeasurementMode = .volume

    private var displayTitle: String {
        detail?.strMeal ?? meal.strMeal
    }

    private var rows: [IngredientDisplayRow] {
        guard let pairs = detail?.ingredients else { return [] }
        return pairs.enumerated().map { index, pair in
            IngredientDisplayRow(
                id: index,
                ingredientName: pair.name,
                measure: pair.measure
            )
        }
    }

    private var equipment: [(emoji: String, name: String)] {
        EquipmentSuggestions.items(strMeal: displayTitle, strCategory: nil)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header

            Group {
                if isLoading {
                    ProgressView("Loading ingredients…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .accessibilityLabel("Loading ingredients")
                        .accessibilityHint("Wait while ingredient data becomes available.")
                } else if let loadError {
                    Text(loadError)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else if rows.isEmpty {
                    Text("No ingredients listed for this recipe.")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    scrollContent
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .task(id: meal.idMeal) {
            await loadDetail()
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 16) {
            if let onBack {
                Button(action: onBack) {
                    Label("Back", systemImage: "chevron.left")
                        .font(.subheadline)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back")
                .accessibilityHint("Return to the recipe list")
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(displayTitle)
                    .font(.title2.weight(.semibold))
                Text("Review ingredients and equipment before cooking.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: onStartRecipe) {
                Label("Start Recipe", systemImage: "arrow.right.circle.fill")
                    .font(.headline)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading || loadError != nil || rows.isEmpty)
            .accessibilityLabel("Start recipe")
            .accessibilityHint("Go to prep steps before cooking")
        }
    }

    private func loadDetail() async {
        isLoading = true
        loadError = nil
        do {
            detail = try await MealService.fetchDetail(id: meal.idMeal)
        } catch {
            loadError = "Could not load recipe details. Check your connection."
            detail = nil
        }
        isLoading = false
    }

    private var scrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                measurementPicker

                VStack(alignment: .leading, spacing: 0) {
                    sectionTitle("Ingredients")
                    ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                        ingredientRow(row)
                        if index < rows.count - 1 {
                            Divider()
                                .padding(.vertical, 6)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 0) {
                    sectionTitle("Equipment")
                        .padding(.top, 8)
                    ForEach(Array(equipment.enumerated()), id: \.offset) { index, item in
                        equipmentRow(emoji: item.emoji, name: item.name)
                        if index < equipment.count - 1 {
                            Divider()
                                .padding(.vertical, 6)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var measurementPicker: some View {
        Picker("Measurement", selection: $measurementMode) {
            ForEach(MeasurementMode.allCases, id: \.self) { mode in
                Text(mode.rawValue).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityLabel("Ingredient amounts measurement")
        .accessibilityHint("Choose Volume or Weight. All ingredient quantities update to match.")
        .accessibilityInputLabels(["Volume", "Weight"])
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.title3.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.bottom, 8)
            .accessibilityAddTraits(.isHeader)
    }

    private func ingredientRow(_ row: IngredientDisplayRow) -> some View {
        let qty = IngredientMeasureConversion.displayQuantity(
            ingredient: row.displayName,
            measure: row.quantityMeasureFragment,
            mode: measurementMode
        )
        return HStack(alignment: .top, spacing: 12) {
            Text(row.emoji)
                .font(.title2)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 4) {
                Text(qty)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(row.displayName)
                    .font(.body.weight(.semibold))
                if !row.preparationNote.isEmpty {
                    Text(row.preparationNote)
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                }
            }
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(row.displayName), \(qty)\(row.preparationNote.isEmpty ? "" : ", \(row.preparationNote)")")
        .accessibilityHint("Ingredient row. Change the measurement control above to hear amounts in volume or weight.")
    }

    private func equipmentRow(emoji: String, name: String) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Text(emoji)
                .font(.title2)
                .accessibilityHidden(true)
            Text(name)
                .font(.body)
            Spacer(minLength: 0)
        }
        .accessibilityLabel("\(name), equipment suggestion")
        .accessibilityHint("Suggested equipment for this recipe category.")
    }
}

// MARK: - Measurement

private enum MeasurementMode: String, CaseIterable {
    case volume = "Volume"
    case weight = "Weight"
}

// MARK: - Row model

private struct IngredientDisplayRow {
    let id: Int
    let emoji: String
    let displayName: String
    let preparationNote: String
    let quantityMeasureFragment: String

    init(id: Int, ingredientName: String, measure: String) {
        self.id = id
        let parsed = IngredientTextParsing.parsedNameAndNote(fromIngredient: ingredientName, measure: measure)
        emoji = IngredientEmoji.bestMatch(for: parsed.name)
        displayName = parsed.name
        preparationNote = parsed.note
        quantityMeasureFragment = parsed.measureForQuantity
    }
}

// MARK: - Parsing

private enum IngredientTextParsing {
    static func parsedNameAndNote(fromIngredient ingredient: String, measure: String) -> (
        name: String,
        note: String,
        measureForQuantity: String
    ) {
        let commaParts = ingredient.split(separator: ",", maxSplits: 1, omittingEmptySubsequences: true)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        var name = ingredient.trimmingCharacters(in: .whitespacesAndNewlines)
        var noteFromIngredient = ""
        if commaParts.count == 2 {
            name = String(commaParts[0])
            noteFromIngredient = String(commaParts[1])
        }

        let measureTrim = measure.trimmingCharacters(in: .whitespacesAndNewlines)
        let (qtyFragment, noteFromMeasure) = splitMeasure(measureTrim)

        let combinedNote = [noteFromIngredient, noteFromMeasure]
            .filter { !$0.isEmpty }
            .joined(separator: " · ")

        return (name, combinedNote, qtyFragment)
    }

    private static func splitMeasure(_ measure: String) -> (quantityPart: String, note: String) {
        guard !measure.isEmpty else { return ("", "") }
        let parts = measure.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard parts.count >= 2 else { return (measure, "") }

        let last = parts.last!.lowercased()
        let looksLikeNote = last.count < 48 && (
            prepHints.contains(where: { last.contains($0) })
            || last.split(separator: " ").count <= 4
        )

        if looksLikeNote {
            let qty = parts.dropLast().joined(separator: ", ")
            return (qty, parts.last!)
        }
        return (measure, "")
    }

    private static let prepHints: [String] = [
        "softened", "chopped", "diced", "minced", "grated", "melted", "sifted", "crushed",
        "optional", "divided", "peeled", "sliced", "halved", "beaten", "cold", "warm", "rough",
        "fine", "packed", "heaping", "level", "thinly", "cubed", "shredded", "to taste",
        "room", "temperature", "large", "small", "medium",
    ]
}

// MARK: - Emoji

private enum IngredientEmoji {
    static func bestMatch(for name: String) -> String {
        let n = name.lowercased()
        let rules: [(String, String)] = [
            ("flour", "\u{1F33E}"),
            ("butter", "\u{1F9C8}"),
            ("egg", "\u{1F95A}"),
            ("milk", "\u{1F95B}"),
            ("cream", "\u{1F95B}"),
            ("cheese", "\u{1F9C0}"),
            ("salt", "\u{1F9C2}"),
            ("pepper", "\u{1F336}\u{FE0F}"),
            ("oil", "\u{1FAD2}"),
            ("vanilla", "\u{1F370}"),
            ("chocolate", "\u{1F36B}"),
            ("cocoa", "\u{2615}"),
            ("cinnamon", "\u{1F33F}"),
            ("honey", "\u{1F36F}"),
            ("almond", "\u{1F330}"),
            ("walnut", "\u{1F330}"),
            ("pecan", "\u{1F330}"),
            ("jam", "\u{1F353}"),
            ("berry", "\u{1F353}"),
            ("lemon", "\u{1F34B}"),
            ("lime", "\u{1F34B}"),
            ("orange", "\u{1F34A}"),
            ("apple", "\u{1F34E}"),
            ("banana", "\u{1F34C}"),
            ("carrot", "\u{1F955}"),
            ("onion", "\u{1F9C5}"),
            ("garlic", "\u{1F9C4}"),
            ("ginger", "\u{1FADA}"),
            ("tomato", "\u{1F345}"),
            ("potato", "\u{1F954}"),
            ("rice", "\u{1F35A}"),
            ("pasta", "\u{1F35D}"),
            ("chicken", "\u{1F414}"),
            ("beef", "\u{1F969}"),
            ("herb", "\u{1F33F}"),
            ("basil", "\u{1F33F}"),
            ("parsley", "\u{1F33F}"),
            ("yeast", "\u{1F35E}"),
            ("sugar", "\u{1F36D}"),
            ("wine", "\u{1F377}"),
            ("coffee", "\u{2615}"),
            ("cornstarch", "\u{1F33D}"),
            ("corn", "\u{1F33D}"),
            ("baking powder", "\u{1F9C1}"),
            ("baking soda", "\u{1F9C1}"),
            ("spice", "\u{1F9C2}"),
        ]
        for (needle, emoji) in rules where n.contains(needle) { return emoji }
        return "\u{1F963}"
    }
}

// MARK: - Equipment

private enum EquipmentSuggestions {
    static func items(strMeal: String, strCategory: String?) -> [(emoji: String, name: String)] {
        var list: [(String, String)] = [
            ("\u{1F373}", "Stovetop or cooktop"),
            ("\u{1F52A}", "Chef's knife and cutting board"),
            ("\u{1F4CF}", "Measuring cups and spoons"),
            ("\u{1F944}", "Mixing spoons or spatula"),
        ]

        let cat = strCategory?.lowercased() ?? ""
        let title = strMeal.lowercased()

        if cat.contains("dessert") || cat.contains("cake") || cat.contains("pie")
            || title.contains("cake") || title.contains("tart") || title.contains("pie") {
            list.insert(("\u{1F963}", "Mixing bowls"), at: 0)
            list.append(("\u{2699}\u{FE0F}", "Whisk or mixer"))
            list.append(("\u{1F525}", "Oven"))
            list.append(("\u{1F967}", "Baking pan or dish"))
        }

        if cat.contains("beef") || cat.contains("chicken") || cat.contains("pork")
            || cat.contains("lamb") || title.contains("roast") {
            list.append(("\u{1F373}", "Skillet or roasting pan"))
        }

        if title.contains("soup") || title.contains("stew") || cat.contains("soup") {
            list.append(("\u{1F372}", "Large pot or Dutch oven"))
        }

        var seen = Set<String>()
        return list.filter { seen.insert($0.1).inserted }
    }
}

// MARK: - Quantity conversion

private enum IngredientMeasureConversion {
    static func displayQuantity(ingredient: String, measure: String, mode: MeasurementMode) -> String {
        let trimmed = measure.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return "as needed" }

        guard let parsed = ParsedAmount.parse(trimmed, ingredientHint: ingredient) else {
            return trimmed
        }

        switch mode {
        case .volume:
            return volumeString(from: parsed, ingredient: ingredient) ?? trimmed
        case .weight:
            return weightString(from: parsed, ingredient: ingredient) ?? trimmed
        }
    }

    private static func gramsPerCup(for ingredient: String) -> Double {
        let n = ingredient.lowercased()
        if n.contains("flour") { return 120 }
        if n.contains("sugar") { return 200 }
        if n.contains("butter") || n.contains("margarine") { return 227 }
        if n.contains("milk") || n.contains("water") || n.contains("cream") { return 240 }
        if n.contains("oil") { return 218 }
        if n.contains("cocoa") { return 85 }
        if n.contains("rice") { return 185 }
        if n.contains("oats") { return 90 }
        if n.contains("honey") || n.contains("syrup") { return 340 }
        return 130
    }

    private static func grams(from parsed: ParsedAmount) -> Double? {
        switch parsed.unit {
        case .grams:
            return parsed.value * parsed.multiplier
        case .kilograms:
            return parsed.value * parsed.multiplier * 1000
        case .ounces:
            return parsed.value * parsed.multiplier * 28.349523125
        case .pounds:
            return parsed.value * parsed.multiplier * 453.59237
        case .cups:
            return parsed.value * parsed.multiplier * gramsPerCup(for: parsed.ingredientHint)
        case .tablespoons:
            return parsed.value * parsed.multiplier * (gramsPerCup(for: parsed.ingredientHint) / 16.0)
        case .teaspoons:
            return parsed.value * parsed.multiplier * (gramsPerCup(for: parsed.ingredientHint) / 48.0)
        case .milliliters:
            return parsed.value * parsed.multiplier
        case .liters:
            return parsed.value * parsed.multiplier * 1000
        case .fluidOunces:
            return parsed.value * parsed.multiplier * 29.5735295625
        case .count, .pinch, .unknown:
            return nil
        }
    }

    private static func cups(from parsed: ParsedAmount, ingredient: String) -> Double? {
        let hint = ingredient
        switch parsed.unit {
        case .cups:
            return parsed.value * parsed.multiplier
        case .tablespoons:
            return parsed.value * parsed.multiplier / 16.0
        case .teaspoons:
            return parsed.value * parsed.multiplier / 48.0
        case .milliliters:
            return parsed.value * parsed.multiplier / 236.5882365
        case .liters:
            return parsed.value * parsed.multiplier * 4.2267528377
        case .fluidOunces:
            return parsed.value * parsed.multiplier / 8.0
        case .grams:
            let g = parsed.value * parsed.multiplier
            return g / gramsPerCup(for: hint)
        case .kilograms:
            return parsed.value * parsed.multiplier * 1000 / gramsPerCup(for: hint)
        case .ounces:
            let g = parsed.value * parsed.multiplier * 28.349523125
            return g / gramsPerCup(for: hint)
        case .pounds:
            let g = parsed.value * parsed.multiplier * 453.59237
            return g / gramsPerCup(for: hint)
        case .count, .pinch, .unknown:
            return nil
        }
    }

    private static func volumeString(from parsed: ParsedAmount, ingredient: String) -> String? {
        if parsed.unit == .count {
            return formatCount(parsed)
        }
        if parsed.unit == .pinch {
            return formatPinch(parsed)
        }
        guard let cupVal = cups(from: parsed, ingredient: ingredient) else { return nil }
        return formatCups(cupVal)
    }

    private static func weightString(from parsed: ParsedAmount, ingredient: String) -> String? {
        if parsed.unit == .count {
            return formatCount(parsed)
        }
        if parsed.unit == .pinch {
            return formatPinch(parsed)
        }
        var p = parsed
        p.ingredientHint = ingredient
        guard let g = grams(from: p) else { return nil }
        if g >= 1000 {
            return String(format: "%.2f kg", g / 1000)
        }
        if g >= 100 {
            return String(format: "%.0f g", g)
        }
        if g >= 10 {
            return String(format: "%.1f g", g)
        }
        return String(format: "%.2f g", g)
    }

    private static func formatCount(_ parsed: ParsedAmount) -> String {
        let v = parsed.value * parsed.multiplier
        let suffix = parsed.suffix.isEmpty ? "" : " \(parsed.suffix)"
        if abs(v - round(v)) < 0.001 {
            return "\(Int(round(v)))\(suffix)"
        }
        return "\(formatDecimal(v))\(suffix)"
    }

    private static func formatPinch(_ parsed: ParsedAmount) -> String {
        let v = parsed.value * parsed.multiplier
        let suffix = parsed.suffix.isEmpty ? "" : " \(parsed.suffix)"
        if v <= 1 { return "pinch\(suffix)" }
        return "\(formatDecimal(v)) pinches\(suffix)"
    }

    private static func formatCups(_ cups: Double) -> String {
        if cups < 1.0 / 48.0 {
            return "dash"
        }
        if cups < 0.5 / 16.0 {
            return String(format: "%.2f tsp", cups * 48)
        }
        if cups < 1.0 / 16.0 {
            return String(format: "%.1f tsp", cups * 48)
        }
        if cups < 1 {
            let tbsp = cups * 16
            if abs(tbsp - round(tbsp)) < 0.08 {
                return "\(Int(round(tbsp))) tbsp"
            }
            return String(format: "%.2f tbsp", tbsp)
        }
        if abs(cups - round(cups)) < 0.06 {
            let w = Int(round(cups))
            return w == 1 ? "1 cup" : "\(w) cups"
        }
        return String(format: "%.2f cups", cups)
    }

    private static func formatDecimal(_ value: Double) -> String {
        if abs(value - round(value)) < 0.001 { return "\(Int(round(value)))" }
        return String(format: "%.2f", value)
    }
}

private struct ParsedAmount {
    var value: Double
    var multiplier: Double
    var unit: UnitKind
    var suffix: String
    var ingredientHint: String

    enum UnitKind {
        case grams, kilograms, ounces, pounds
        case cups, tablespoons, teaspoons
        case milliliters, liters, fluidOunces
        case count, pinch, unknown
    }

    static func parse(_ raw: String, ingredientHint: String) -> ParsedAmount? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return nil }

        // Insert a space between a digit and a letter so "200g" and "1cup" parse reliably.
        let normalized = trimmed.replacingOccurrences(
            of: #"(\d)([A-Za-z])"#,
            with: "$1 $2",
            options: .regularExpression
        )

        let lowered = normalized.lowercased()
        if lowered.contains("pinch") || lowered == "dash" {
            return ParsedAmount(value: 1, multiplier: 1, unit: .pinch, suffix: "", ingredientHint: ingredientHint)
        }

        guard let (numberToken, rest) = extractLeadingNumericToken(normalized) else {
            return nil
        }
        guard let baseValue = parseNumberToken(numberToken) else { return nil }

        let tail = rest.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if tail.isEmpty {
            return ParsedAmount(value: baseValue, multiplier: 1, unit: .count, suffix: "", ingredientHint: ingredientHint)
        }

        if let kind = matchUnit(tail) {
            let suffix = stripLeadingUnit(from: tail, unit: kind)
            return ParsedAmount(value: baseValue, multiplier: 1, unit: kind, suffix: suffix, ingredientHint: ingredientHint)
        }

        return ParsedAmount(value: baseValue, multiplier: 1, unit: .count, suffix: tail, ingredientHint: ingredientHint)
    }

    private static func extractLeadingNumericToken(_ raw: String) -> (String, String)? {
        let s = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.isEmpty { return nil }

        let parts = s.split(separator: " ", omittingEmptySubsequences: true)
        guard let first = parts.first else { return nil }

        if parts.count >= 2 {
            let second = String(parts[1])
            if parseFraction(second) != nil {
                let combined = "\(first) \(second)"
                let restStart = s.range(of: combined)?.upperBound ?? s.endIndex
                let rest = String(s[restStart...])
                return (combined, rest)
            }
        }

        let restStart = first.endIndex
        if restStart < s.endIndex {
            let idx = s.index(after: first.endIndex)
            let rest = String(s[idx...]).trimmingCharacters(in: .whitespaces)
            return (String(first), rest)
        }
        return (String(first), "")
    }

    private static func parseNumberToken(_ token: String) -> Double? {
        let t = token.trimmingCharacters(in: .whitespacesAndNewlines)
        let sub = t.split(separator: " ")
        if sub.count == 2, let whole = Double(sub[0]), let frac = parseFraction(String(sub[1])) {
            return whole + frac
        }
        if let frac = parseFraction(t) { return frac }
        return Double(t)
    }

    private static func parseFraction(_ token: String) -> Double? {
        if token.contains("/") {
            let p = token.split(separator: "/")
            guard p.count == 2, let a = Double(p[0]), let b = Double(p[1]), b != 0 else { return nil }
            return a / b
        }
        return nil
    }

    private static func matchUnit(_ tail: String) -> ParsedAmount.UnitKind? {
        if tail.hasPrefix("kg") { return .kilograms }
        if tail.hasPrefix("kilogram") { return .kilograms }
        if tail.hasPrefix("grams") || tail.hasPrefix("gram") { return .grams }
        if tail == "g" || tail.hasPrefix("g ") { return .grams }

        if tail.hasPrefix("pound") || tail.hasPrefix("lb") { return .pounds }
        if tail.hasPrefix("ounce") || tail.hasPrefix("oz") { return .ounces }

        if tail.hasPrefix("tablespoon") || tail.hasPrefix("tbsp") || tail.hasPrefix("tbs") { return .tablespoons }
        if tail.hasPrefix("teaspoon") || tail.hasPrefix("tsp") { return .teaspoons }
        if tail.hasPrefix("cup") || tail.hasPrefix("cups") { return .cups }

        if tail.hasPrefix("milliliter") || tail.hasPrefix("ml") { return .milliliters }
        if tail.hasPrefix("liter") || tail.hasPrefix("litre") { return .liters }
        if tail == "l" || tail.hasPrefix("l ") { return .liters }

        if tail.hasPrefix("fluid ounce") || tail.hasPrefix("fl oz") || tail.hasPrefix("fl. oz") {
            return .fluidOunces
        }
        return nil
    }

    private static func stripLeadingUnit(from tail: String, unit: ParsedAmount.UnitKind) -> String {
        var s = tail
        let prefixes: [ParsedAmount.UnitKind: [String]] = [
            .kilograms: ["kilograms", "kilogram", "kg"],
            .grams: ["grams", "gram", "g"],
            .pounds: ["pounds", "pound", "lb", "lbs"],
            .ounces: ["ounces", "ounce", "oz"],
            .tablespoons: ["tablespoons", "tablespoon", "tbsp", "tbs"],
            .teaspoons: ["teaspoons", "teaspoon", "tsp"],
            .cups: ["cups", "cup"],
            .milliliters: ["milliliters", "milliliter", "ml"],
            .liters: ["liters", "liter", "litres", "litre", "l"],
            .fluidOunces: ["fluid ounces", "fluid ounce", "fl oz", "fl. oz"],
        ]
        guard let options = prefixes[unit] else { return "" }
        for p in options.sorted(by: { $0.count > $1.count }) {
            if s.hasPrefix(p) {
                s.removeFirst(p.count)
                return s.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        return ""
    }
}

#Preview {
    IngredientsAndEquipmentView(
        meal: Meal(idMeal: "52767", strMeal: "Bakewell tart", strMealThumb: ""),
        onBack: {},
        onStartRecipe: {}
    )
}
