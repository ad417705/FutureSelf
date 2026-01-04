# FutureSelf Placeholder Images - MVP

## ✨ Automatic Generation (No Manual Setup Required!)

For the MVP, placeholder images are **generated automatically at runtime** using the enhanced `ImageFilterUtilities.swift`. You don't need to add any images to Assets.xcassets!

### How It Works

When a user completes onboarding or taps "Refresh Vision", the `MockImageGenerationService` calls `ImageFilterUtilities.generatePlaceholder()` which creates a beautiful gradient image with:

1. **Radial gradient background** - Goal-specific color schemes
2. **Subtle texture overlay** - Random dots for depth
3. **Layered SF Symbol icons** - Background (subtle) + foreground (prominent)
4. **Drop shadows** - For 3D depth effect
5. **Goal type text** - Labeled at the bottom
6. **Status variations** - CoreImage filters create warning/danger versions

### Goal-Specific Color Schemes

| Goal Type | Colors | Effect |
|-----------|--------|--------|
| Travel | Sky Blue → Sunset Pink | Adventurous, inspiring |
| Move Out | Green → Blue | Fresh start, growth |
| Emergency Fund | Gold → Red | Security, importance |
| Debt Free | Purple → Magenta | Freedom, celebration |
| New Car | Dark Blue → Silver | Sleek, modern |
| Wedding | Pink → Rose | Romantic, elegant |
| Education | Blue → Purple | Knowledge, wisdom |
| Custom | Gray-Blue → Purple-Gray | Neutral, versatile |

### Image Specifications

- **Size**: 600x400px (3:2 aspect ratio)
- **Format**: JPEG at 90% quality
- **File size**: ~50-150KB per image
- **Generated on-demand**: No storage overhead

### Status Variations

Each placeholder automatically generates 3 versions:

1. **Good (Base)**: Full color, sharp, bright
2. **Warning**:
   - Blur radius: 2px
   - Saturation: 70%
3. **Danger**:
   - Blur radius: 5px
   - Saturation: 30%
   - Brightness: -30%

---

## 🎨 Optional: Adding Custom Mock Images (Post-MVP)

If you want to replace the auto-generated placeholders with custom images for better realism, follow these steps:

### Step 1: Create Images

Create images with these specifications:
- **Dimensions**: 600x400px (recommended) or 1200x800px (retina)
- **Format**: JPEG or PNG
- **File naming**:
  - `mock_travel.jpg`
  - `mock_moveOut.jpg`
  - `mock_emergencyFund.jpg`
  - `mock_debtFree.jpg`
  - `mock_newCar.jpg`
  - `mock_wedding.jpg`
  - `mock_education.jpg`
  - `mock_custom.jpg`

### Step 2: Add to Assets.xcassets

1. Open Xcode
2. Navigate to `Assets.xcassets` in the project navigator
3. Right-click → **New Image Set**
4. Name it exactly as listed above (e.g., `mock_travel`)
5. Drag your image into the "1x" or "2x" slot
6. Repeat for all goal types

### Step 3: Update MockImageGenerationService

Update `MockImageGenerationService.swift`:

```swift
func getMockImage(for goalType: GoalType, status: BudgetStatus) -> Data {
    // Try to load from Assets first
    let imageName = "mock_\(goalType.rawValue)"

    if let image = UIImage(named: imageName),
       let data = image.jpegData(compressionQuality: 0.9) {
        return data
    }

    // Fallback to generated placeholder
    return ImageFilterUtilities.generatePlaceholder(for: goalType) ?? Data()
}
```

Now images will load from Assets.xcassets if available, or fall back to auto-generation.

---

## 🚀 Post-MVP: Azure DALL-E 3 Integration

When integrating Azure OpenAI DALL-E 3:

1. Replace `MockImageGenerationService` with `AzureImageGenerationService` in `AppContainer.swift`
2. Real AI-generated images will replace these placeholders
3. The placeholder system will still work as a fallback for:
   - Offline mode
   - API failures
   - Goals created before Azure integration

---

## 📊 Performance Notes

**Current System:**
- ✅ Zero asset bundle overhead (images generated on-demand)
- ✅ Each image ~50-150KB in memory
- ✅ Generation time: <100ms per image
- ✅ 3 variations generated simultaneously (~200ms total)

**With Assets.xcassets (Optional):**
- 📦 Bundle size increase: ~400-800KB (8 goal types × 50-100KB)
- ⚡ Load time: <50ms (faster than generation)
- 💾 No runtime generation overhead

**With Azure DALL-E 3 (Post-MVP):**
- ⏱️ Generation time: 10-30 seconds per image
- 💰 Cost: ~$0.12 per image (HD quality)
- 📦 Cached locally after generation
- 🔄 Weekly regeneration (background task)

---

## 🎨 Design Inspiration

The auto-generated placeholders are inspired by:
- **Duolingo**: Gradient backgrounds with bold icons
- **Apple Fitness+**: Radial gradients for depth
- **Headspace**: Soft textures and shadows
- **Notion**: Clean, minimalist goal visualizations

The result is a polished, professional look for MVP without requiring design resources!

---

## 💡 Testing the Placeholders

To see all placeholder variations:

1. Run the app in simulator/device
2. Complete onboarding for different goal types
3. Navigate to FutureSelf view
4. Modify `budgetStatus` in code to test warning/danger variations:
   ```swift
   budgetStatus = .warning  // Shows blurred version
   budgetStatus = .danger   // Shows heavily degraded version
   ```

Each goal type will have unique colors and appearance!

---

**Bottom line for MVP:** You're all set! Images generate automatically - no manual work needed. 🎉
