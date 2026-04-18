# Recipository

A visionOS hands-free cooking assistant.

## Navigation Flow

```
Voice Commands → Recipe List → Recipe (tabs: Steps | Ingredients | Timer | Rating)
```

## File Tree

```
Recipository/
│
├── RecipositoryApp.swift              ← App entry point & window config (Shared)
├── ContentView.swift                  ← Router — decides which page to show (Shared)
├── MealService.swift                  ← API service & Meal data model (Shared)
│
├── PAGE 1: Voice Commands
│   └── VoiceCommandsView.swift        ← Welcome notice with voice command list
│
├── PAGE 2: Recipe List
│   └── RecipeListView.swift           ← Browse desserts from TheMealDB API
│
└── PAGE 3: Recipe (Cooking View)
    ├── RecipeView.swift               ← Glass bubble container + tab bar (Shared)
    │
    ├── TAB: Steps
    │   └── RecipeStepView.swift       ← Step-by-step cooking instructions
    │
    ├── TAB: Ingredients
    │   └── IngredientsAndEquipmentView.swift ← Ingredient list & equipment
    │
    ├── TAB: Timer
    │   └── TimerView.swift            ← Countdown timer
    │
    └── TAB: Rating
        └── RatingView.swift           ← Rate the recipe
```

## Who Works on What

| File | Owner | Status |
|------|-------|--------|
| `RecipeStepView.swift` | | Placeholder |
| `IngredientsAndEquipmentView.swift` | | Placeholder |
| `TimerView.swift` | | Placeholder |
| `RatingView.swift` | | Placeholder |

Fill in the **Owner** column so everyone knows who's building what.
