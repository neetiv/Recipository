# Recipository

A visionOS hands-free cooking assistant.

## File Structure

| File | Owner | Description |
|------|-------|-------------|
| `ContentView.swift` | Shared | Router — controls which page is displayed |
| `VoiceCommandsView.swift` | | Welcome notice showing available voice commands |
| `IngredientsAndEquipmentView.swift` | | Ingredients list and required equipment |
| `RatingView.swift` | | Recipe rating and feedback |
| `RecipeView.swift` | | Step-by-step cooking instructions |
| `RecipositoryApp.swift` | Shared | App entry point and window configuration |

## Pages

### Voice Commands
Initial screen shown on app launch. Lists available voice commands for hands-free navigation.

### Ingredients & Equipment
Displays the ingredient list and any equipment needed before starting a recipe.

### Rating
Allows users to rate a recipe after cooking.

### Recipe
The main cooking view — walks through recipe steps one at a time.

## Navigation Flow
```
Voice Commands → Recipe → (Ingredients & Equipment, Rating)
```
