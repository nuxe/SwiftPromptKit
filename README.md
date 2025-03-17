Create a Swift UIKit equivalent of the Prompt-Kit component library, designed specifically for developing AI-driven chat interfaces in iOS apps. The framework should emphasize modularity, ease of integration, and customizable aesthetics, allowing developers to rapidly prototype and build conversational interfaces with the following key components:

PromptInputView: A user-friendly input component that supports text entry, placeholder hints, send actions, and input validation.

MessageBubbleView: Customizable chat bubbles for messages, differentiating between user and AI-generated content, with support for text formatting and interactive elements.

MarkdownRenderer: A SwiftUI view or UIKit component capable of rendering Markdown-formatted text with support for rich formatting including bold, italic, bullet lists, links, and code blocks.

AutoScrollingChatView: A responsive, scrollable chat container that automatically scrolls to the latest message, enhancing the user experience during live interactions.

LoadingIndicatorView: A visually appealing loader to indicate processing or awaiting AI responses.

PromptSuggestionView: Interactive prompts or suggestion chips to guide user interaction and improve engagement.

RealTimeResponseHandler: Logic to handle streaming responses from AI models, updating UI dynamically as content arrives.

ReasoningDisclosureView: Optional expandable view to display the AI model's reasoning steps, enhancing transparency and trust.

Ensure modularity, clarity, and extensibility. Prioritize clean, reusable SwiftUI components or UIKit views wrapped for SwiftUI compatibility, structured clearly for maintainability.

Swift UIKit component demo app that:
    •    Shows a UITableView with a list of all Prompt-Kit UI components.
    •    When a component name is tapped, navigates (pushes) to a UIViewController demonstrating the selected component embedded in a minimal, interactive example view.
    •    Each demo UIViewController should clearly showcase essential interactions and states of its component.
    •    Display an error message if the user taps on a component that has not been implemented yet
    •    Structure the code cleanly with clear navigation logic and reusable component views.
    •    Follow UIKit best practices for readability, maintainability, and simplicity.
    
