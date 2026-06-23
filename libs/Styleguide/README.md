# Styleguide Library

A comprehensive design system for iOS apps built with Swift Package Manager.

## 🎨 Design Philosophy

The Styleguide library follows a **typography-first approach** where all UI elements use predefined typography styles instead of raw fonts. This ensures consistency and maintainability across your app.

## 📦 Components

### Typography System

Instead of using raw fonts, use semantic typography styles:

```swift
import Styleguide

// ✅ Good - Use semantic styles
let titleLabel = StyleLabel(style: .title, text: "Welcome")
let bodyLabel = StyleLabel(style: .body, text: "This is body text")

// ❌ Avoid - Don't use raw fonts
let label = UILabel()
label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
```

### Available Typography Styles

#### Display & Headlines
- `.display` - Large display text (40pt, bold)
- `.headline` - Section headlines (32pt, bold)

#### Titles
- `.titleLarge` - Large titles (28pt, semibold)
- `.title` - Standard titles (24pt, semibold)
- `.subtitle` - Subtitles (20pt, medium)

#### Body Text
- `.bodyLarge` - Large body text (18pt, regular)
- `.body` - Standard body text (16pt, regular)
- `.bodyMedium` - Medium weight body (16pt, medium)
- `.bodySmall` - Small body text (14pt, regular)

#### Labels
- `.labelLarge` - Large labels (16pt, medium)
- `.label` - Standard labels (14pt, medium)
- `.labelSmall` - Small labels (12pt, medium)

#### Captions
- `.caption` - Standard captions (12pt, regular)
- `.captionMedium` - Medium weight captions (12pt, medium)

#### Buttons
- `.buttonLarge` - Large buttons (18pt, semibold)
- `.button` - Standard buttons (16pt, semibold)
- `.buttonSmall` - Small buttons (14pt, semibold)

#### Text Fields
- `.textFieldLarge` - Large text fields (18pt, regular)
- `.textField` - Standard text fields (16pt, regular)
- `.textFieldSmall` - Small text fields (14pt, regular)

## 🧩 UI Components

### StyleLabel

```swift
// Create labels with semantic styles
let titleLabel = StyleLabel(style: .title, text: "My Title")
let bodyLabel = StyleLabel(style: .body, text: "Body text")

// Convenience methods
let displayLabel = StyleLabel.display("Display Text")
let headlineLabel = StyleLabel.headline("Headline")
let captionLabel = StyleLabel.caption("Caption text")

// Customize colors
titleLabel.setTextColorStyle(.textPrimary)
bodyLabel.setTextColorStyle(.textSecondary)
```

### StyleButton

```swift
// Create buttons with different styles and sizes
let primaryButton = StyleButton(style: .primary, size: .medium)
let secondaryButton = StyleButton(style: .secondary, size: .large)
let destructiveButton = StyleButton(style: .destructive, size: .small)

// Set titles (typography is automatically applied)
primaryButton.setTitle("Save", for: .normal)
secondaryButton.setTitle("Cancel", for: .normal)

// Or use the convenient initializer with title
let saveButton = StyleButton(style: .primary, size: .medium, title: "Save")
let cancelButton = StyleButton(style: .secondary, size: .medium, title: "Cancel")

// Loading states
primaryButton.isLoading = true
```

### StyleTextField

```swift
// Create text fields with different styles
let emailField = StyleTextField(style: .outlined, size: .medium)
let searchField = StyleTextField(style: .search, size: .large)

// Set placeholders
emailField.placeholder = "Enter your email"
searchField.placeholder = "Search..."

// Error handling
emailField.setError("Please enter a valid email")
```

### StyleCard

```swift
// Create cards with different styles
let elevatedCard = StyleCard(style: .elevated, size: .medium)
let outlinedCard = StyleCard(style: .outlined, size: .large)

// Add content
let label = StyleLabel(style: .body, text: "Card content")
elevatedCard.addContent(label)
```

## 🎨 Color System

Use semantic colors instead of raw colors:

```swift
// Text colors
Colors.color(for: .textPrimary)
Colors.color(for: .textSecondary)
Colors.color(for: .textError)

// Background colors
Colors.color(for: .backgroundPrimary)
Colors.color(for: .backgroundSecondary)

// Button colors
Colors.color(for: .buttonPrimary)
Colors.color(for: .buttonSecondary)
```

## 📏 Spacing System

Use the 8pt grid system:

```swift
// Spacing scale
Spacing.Scale.xs.rawValue    // 4pt
Spacing.Scale.sm.rawValue    // 8pt
Spacing.Scale.md.rawValue    // 16pt
Spacing.Scale.lg.rawValue    // 24pt
Spacing.Scale.xl.rawValue    // 32pt

// Semantic spacing
Spacing.Semantic.componentPadding
Spacing.Semantic.screenMargin
Spacing.Semantic.buttonHeight
```

## 🔧 Configuration

Configure the styleguide globally:

```swift
// Configure theme
StyleguideConfig.shared.configure(
    primaryColor: .systemBlue,
    accentColor: .systemPurple,
    useCompactSpacing: false
)

// Enable dark mode support
StyleguideConfig.shared.enableDarkMode()
```

## 🚀 Getting Started

1. Import the Styleguide library:
```swift
import Styleguide
```

2. Use semantic components instead of UIKit components:
```swift
// Instead of UILabel
let label = StyleLabel(style: .body, text: "Hello World")

// Instead of UIButton
let button = StyleButton(style: .primary, size: .medium)
button.setTitle("Tap me", for: .normal)
```

3. Apply typography styles consistently:
```swift
// All text should use predefined styles
titleLabel.setStyle(.title)
bodyLabel.setStyle(.body)
captionLabel.setStyle(.caption)
```

## 📝 Best Practices

1. **Always use semantic styles** - Never use raw fonts or colors
2. **Be consistent** - Use the same typography styles for similar content
3. **Follow the 8pt grid** - Use spacing constants for layout
4. **Use semantic colors** - Colors should have meaning (primary, error, etc.)
5. **Test in both light and dark modes** - The color system supports both

## 🔍 Live Previews

The Styleguide library includes comprehensive live previews using iOS 17+ native UIKit previews. When you import the library in your project, you can see live previews of all components directly in Xcode.

### Available Previews

- **Button Styles** - All button variants, sizes, and states
- **Typography Scale** - Complete typography hierarchy
- **Color Palette** - All semantic colors and variations
- **Card Components** - Different card styles and layouts
- **Text Fields** - All input styles and error states
- **Form Layouts** - Complete form examples
- **Dark Mode** - All components in dark appearance
- **Accessibility** - Dynamic Type and high contrast support

### How to Use Previews

1. Import the Styleguide library in your project
2. Open any component file (e.g., `Button.swift`, `Label.swift`)
3. Click the "Preview" button in Xcode's canvas
4. See live, interactive previews of all component variations

### Preview Features

- **Live Updates** - Changes to code instantly reflect in previews
- **Multiple Variants** - Each component shows different styles and states
- **Device Sizes** - Previews work across different device sizes
- **Dark Mode** - Toggle between light and dark appearances
- **Accessibility** - Test with different text sizes and contrast settings
- **Simplified API** - Minimal boilerplate with helper utilities

### Preview Helpers

The library includes helper utilities to reduce preview boilerplate:

```swift
// Simple container
PreviewContainer.create {
    UIStackView.vertical {
        [component1, component2, component3]
    }
}

// Scrollable container
PreviewContainer.createScrollable {
    UIStackView.vertical {
        [many, components, here]
    }
}

// Section with title
PreviewSection.create(title: "My Section") {
    UIStackView.vertical {
        [components]
    }
}

// Component grid
ComponentGrid.create(columns: 2) {
    [item1, item2, item3, item4]
}

// Button group
ButtonGroup.create {
    [button1, button2, button3]
}

// Form layout
FormPreview.create(title: "Contact Form") {
    [field1, field2, buttonGroup]
}
```

## 🎯 Benefits

- **Consistency** - All UI elements follow the same design system
- **Maintainability** - Change typography globally by updating styles
- **Accessibility** - Built-in support for dynamic type and dark mode
- **Developer Experience** - Type-safe, autocomplete-friendly API with live previews
- **Performance** - Optimized for iOS with proper font caching
- **Live Previews** - See components in action without running the app
