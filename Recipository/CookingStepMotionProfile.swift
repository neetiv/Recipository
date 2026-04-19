//
//  CookingStepMotionProfile.swift
//  Recipository
//
//  Classifies a recipe step string so hand tracking runs only when relevant.
//

import Foundation

/// High-level motion category inferred from step text (keyword + light parsing).
enum CookingMotionKind: Equatable {
    /// No hand-coaching for this step — tracking session stays off.
    case inactive
    /// Stir / mix / fold / whisk style motion.
    case mixing(targetDuration: TimeInterval?)
    case kneading
    case pouring
    case chopping
    /// Step implies ongoing work but no specific motion bucket.
    case generalActive
}

enum CookingStepMotionProfile {
    /// Parses instruction text into a motion profile. All logic is local (no network).
    static func parse(_ text: String) -> CookingMotionKind {
        let lower = text.lowercased()

        if mixingKeywords.contains(where: { lower.contains($0) }) {
            return .mixing(targetDuration: extractDurationSeconds(lower))
        }
        if kneadingKeywords.contains(where: { lower.contains($0) }) {
            return .kneading
        }
        if pouringKeywords.contains(where: { lower.contains($0) }) {
            return .pouring
        }
        if choppingKeywords.contains(where: { lower.contains($0) }) {
            return .chopping
        }
        if activeGeneralKeywords.contains(where: { lower.contains($0) }) {
            return .generalActive
        }
        return .inactive
    }

    private static let mixingKeywords: [String] = [
        "mix", "stir", "fold", "whisk", "beat", "blend", "combine", "incorporate",
    ]

    private static let kneadingKeywords: [String] = [
        "knead", "kneading",
    ]

    private static let pouringKeywords: [String] = [
        "pour", "drizzle", "transfer liquid",
    ]

    private static let choppingKeywords: [String] = [
        "chop", "dice", "slice", "mince", "cut", "julienne", "grate",
    ]

    private static let activeGeneralKeywords: [String] = [
        "stir constantly", "keep stirring", "continue mixing", "roll out", "shape",
    ]

    /// Extracts a duration in seconds from phrases like "for 2 minutes" or "30 seconds".
    private static func extractDurationSeconds(_ lower: String) -> TimeInterval? {
        // "for 2 minutes" / "for 30 seconds"
        let pattern = #"(\d+)\s*(minute|minutes|min|second|seconds|sec)\b"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { return nil }
        let range = NSRange(lower.startIndex..., in: lower)
        guard let match = regex.firstMatch(in: lower, options: [], range: range),
              match.numberOfRanges >= 3,
              let numRange = Range(match.range(at: 1), in: lower),
              let unitRange = Range(match.range(at: 2), in: lower),
              let value = Double(lower[numRange]) else { return nil }
        let unit = String(lower[unitRange])
        if unit.hasPrefix("min") {
            return value * 60
        }
        return value
    }
}
