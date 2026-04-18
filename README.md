# Recipository

A visionOS hands-free cooking assistant.

## File Structure

| File | Owner | Description |
|------|-------|-------------|
| `ContentView.swift` | Shared | Router — controls which page is displayed |
| `VoiceCommandsView.swift` | | Welcome notice showing available voice commands |
| `RecipeListView.swift` | Shared | Browse and choose a dessert recipe (API) |
| `MealService.swift` | Shared | API service and Meal data model |
| `RecipeView.swift` | Shared | Glass bubble container with tab bar |
| `RecipeStepView.swift` | | Step-by-step cooking instructions (tab) |
| `IngredientsAndEquipmentView.swift` | | Ingredients list and required equipment (tab) |
| `TimerView.swift` | | Countdown timer (tab) |
| `RatingView.swift` | | Recipe rating and feedback (tab) |
| `RecipositoryApp.swift` | Shared | App entry point and window configuration |

## Pages

### Voice Commands
Initial screen shown on app launch. Lists available voice commands for hands-free navigation.

### Recipe List
Browse desserts fetched from TheMealDB API. Tap a recipe to start cooking.

### Recipe (Cooking View)
One glass bubble with 4 tabs at the bottom. Each tab is a separate file so teammates can work in parallel:
- **Steps** → `RecipeStepView.swift`
- **Ingredients** → `IngredientsAndEquipmentView.swift`
- **Timer** → `TimerView.swift`
- **Rating** → `RatingView.swift`

## Navigation Flow
```
Voice Commands → Recipe List → Recipe (tabs: Steps | Ingredients | Timer | Rating)
```
