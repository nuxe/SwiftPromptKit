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