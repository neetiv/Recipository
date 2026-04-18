# Recipository

A visionOS hands-free cooking assistant.

## Navigation Flow

```
Voice Commands → Recipe List → Recipe (cooking workspace)
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
└── PAGE 3: Recipe (Cooking Workspace)
    ├── RecipeView.swift               ← Layout container (Shared)
    │
    ├── STEP BAR (top, wide)
    │   └── RecipeStepView.swift       ← Current step instructions
    │
    ├── TIMER (top right, small)
    │   └── TimerView.swift            ← Countdown timer
    │
    ├── BUTTON: Ingredients
    │   └── IngredientsAndEquipmentView.swift
    │
    ├── BUTTON: Method
    │   └── MethodView.swift
    │
    └── BUTTON: Finished Product
        └── FinishedProductView.swift
```

## Cooking Workspace Layout

```
┌──────────────────────────────┐  ┌─────────┐
│            step              │  │  timer   │
└──────────────────────────────┘  └─────────┘
┌─────────────┐ ┌────────┐ ┌─────────────────┐
│ ingredients │ │ method │ │ finished product │
└─────────────┘ └────────┘ └─────────────────┘

          ( workspace stays clear )
```

## Who Works on What

| File | Owner | Status |
|------|-------|--------|
| `RecipeStepView.swift` | | Placeholder |
| `TimerView.swift` | | Placeholder |
| `IngredientsAndEquipmentView.swift` | | Placeholder |
| `MethodView.swift` | | Placeholder |
| `FinishedProductView.swift` | | Placeholder |

Fill in the **Owner** column so everyone knows who's building what.
