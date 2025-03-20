# PromptInputView

A user-friendly input component for text entry in AI-driven chat interfaces.

## Features

- Text input with placeholder support
- Auto-expanding text area with configurable maximum height
- Submit button with loading state
- Support for custom action buttons with tooltips
- Accessibility support

## Usage

### Basic Implementation

```swift
// Create the input view
let promptInputView = PromptInputView()
promptInputView.translatesAutoresizingMaskIntoConstraints = false
promptInputView.placeholder = "Ask me anything..."
promptInputView.delegate = self

// Add to your view
view.addSubview(promptInputView)

// Set up constraints
NSLayoutConstraint.activate([
    promptInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
    promptInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
    promptInputView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -16)
])

// Implement the delegate
extension YourViewController: PromptInputViewDelegate {
    func promptInputView(_ inputView: PromptInputView, didSubmitText text: String) {
        // Handle submitted text
        print("User submitted: \(text)")
        
        // Show loading state
        inputView.isLoading = true
        
        // Process the input (e.g., send to an API)
        // ...
        
        // When processing is complete, hide loading state and clear input
        inputView.isLoading = false
        inputView.clearText()
    }
    
    func promptInputView(_ inputView: PromptInputView, didChangeText text: String) {
        // Optional: handle text changes (e.g., show typing indicators)
    }
}
```

### Adding Custom Action Buttons

```swift
// Add attachment button
let attachmentImage = UIImage(systemName: "paperclip")!
promptInputView.addActionButton(
    image: attachmentImage,
    accessibilityLabel: "Attach file",
    tooltip: "Attach a file",
    action: {
        // Handle attachment action
    }
)

// Add voice input button
let microphoneImage = UIImage(systemName: "mic")!
promptInputView.addActionButton(
    image: microphoneImage,
    accessibilityLabel: "Voice input",
    tooltip: "Record voice",
    action: {
        // Handle voice input action
    }
)
```

## Properties

- `delegate: PromptInputViewDelegate?` - The delegate to handle input events
- `text: String` - The current text in the input field
- `placeholder: String?` - The placeholder text to display when the input is empty
- `maxHeight: CGFloat` - The maximum height the text view can expand to (default: 120)
- `isLoading: Bool` - Whether the input view is in a loading state
- `isEnabled: Bool` - Whether the input view is enabled

## Methods

- `clearText()` - Clears the text in the input field
- `addActionButton(image:accessibilityLabel:tooltip:action:)` - Adds a custom action button to the input view

## Notes

- The PromptInputView automatically handles keyboard avoidance when used with the `keyboardLayoutGuide`
- For best results, set the `delegate` before adding to the view hierarchy
- The component automatically resizes the text input area based on content, up to the specified `maxHeight`

## MarkdownRendererView

A UIKit view component that renders Markdown-formatted text with support for various formatting elements and interactive features.

### Features

- Text formatting (bold, italic)
- Headings (H1-H6)
- Lists (ordered and unordered)
- Links with tap handling
- Code blocks with syntax highlighting
- Blockquotes
- Dark/light mode theme switching

### Usage

```swift
// Create a MarkdownRendererView
let markdownRenderer = MarkdownRendererView()

// Set a delegate to handle interactions
markdownRenderer.delegate = self

// Render markdown text
markdownRenderer.render(markdown: """
# Heading 1
This is **bold** and *italic* text.

- List item 1
- List item 2

[Visit website](https://example.com)

```swift
// Code block
let greeting = "Hello, world!"
```

> This is a blockquote.
""")

// Optional: Switch between themes
markdownRenderer.setTheme(.darkMode)
// or
markdownRenderer.setTheme(.lightMode)
```

### Delegate Methods

Implement `MarkdownRendererViewDelegate` to handle user interactions:

```swift
func markdownRendererView(_ rendererView: MarkdownRendererView, didTapLink url: URL) {
    // Handle link tap
}

func markdownRendererView(_ rendererView: MarkdownRendererView, didTapCodeBlock code: String, language: String) {
    // Handle code block tap
}
```

### Customizing Theme

Create custom themes by initializing a `MarkdownTheme` with your preferred styling:

```swift
let customTheme = MarkdownTheme(
    font: .systemFont(ofSize: 16),
    boldFont: .boldSystemFont(ofSize: 16),
    italicFont: .italicSystemFont(ofSize: 16),
    codeFont: .monospacedSystemFont(ofSize: 14, weight: .regular),
    headingFonts: [
        .boldSystemFont(ofSize: 24), // H1
        .boldSystemFont(ofSize: 22), // H2
        .boldSystemFont(ofSize: 20), // H3
        .boldSystemFont(ofSize: 18), // H4
        .boldSystemFont(ofSize: 16), // H5
        .boldSystemFont(ofSize: 14)  // H6
    ],
    textColor: .label,
    linkColor: .systemBlue,
    codeBackgroundColor: .secondarySystemBackground,
    blockquoteBackgroundColor: .secondarySystemBackground,
    blockquoteIndicatorColor: .systemGreen,
    lineSpacing: 4.0,
    paragraphSpacing: 8.0
)

markdownRenderer.setTheme(customTheme)
``` 