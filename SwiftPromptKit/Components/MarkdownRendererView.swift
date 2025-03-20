import UIKit

/// A protocol that defines methods for the MarkdownRendererView delegate
public protocol MarkdownRendererViewDelegate: AnyObject {
    /// Called when a link is tapped in the markdown content
    func markdownRendererView(_ rendererView: MarkdownRendererView, didTapLink url: URL)
    
    /// Called when a code block is tapped
    func markdownRendererView(_ rendererView: MarkdownRendererView, didTapCodeBlock code: String, language: String)
}

/// Theme configuration for the markdown renderer
public struct MarkdownTheme {
    /// Font for regular text
    public let font: UIFont
    /// Font for bold text
    public let boldFont: UIFont
    /// Font for italic text
    public let italicFont: UIFont
    /// Font for code blocks
    public let codeFont: UIFont
    /// Font for headings (h1-h6)
    public let headingFonts: [UIFont]
    
    /// Text color
    public let textColor: UIColor
    /// Link color
    public let linkColor: UIColor
    /// Code background color
    public let codeBackgroundColor: UIColor
    /// Blockquote background color
    public let blockquoteBackgroundColor: UIColor
    /// Blockquote indicator color
    public let blockquoteIndicatorColor: UIColor
    
    /// Line spacing
    public let lineSpacing: CGFloat
    /// Paragraph spacing
    public let paragraphSpacing: CGFloat
    
    /// Initialize with default values
    public init(
        font: UIFont = .systemFont(ofSize: 16),
        boldFont: UIFont = .boldSystemFont(ofSize: 16),
        italicFont: UIFont = .italicSystemFont(ofSize: 16),
        codeFont: UIFont = .monospacedSystemFont(ofSize: 14, weight: .regular),
        headingFonts: [UIFont] = [
            .boldSystemFont(ofSize: 24),
            .boldSystemFont(ofSize: 22),
            .boldSystemFont(ofSize: 20),
            .boldSystemFont(ofSize: 18),
            .boldSystemFont(ofSize: 16),
            .boldSystemFont(ofSize: 14)
        ],
        textColor: UIColor = .label,
        linkColor: UIColor = .systemBlue,
        codeBackgroundColor: UIColor = .secondarySystemBackground,
        blockquoteBackgroundColor: UIColor = .secondarySystemBackground,
        blockquoteIndicatorColor: UIColor = .systemGreen,
        lineSpacing: CGFloat = 4.0,
        paragraphSpacing: CGFloat = 8.0
    ) {
        self.font = font
        self.boldFont = boldFont
        self.italicFont = italicFont
        self.codeFont = codeFont
        self.headingFonts = headingFonts
        self.textColor = textColor
        self.linkColor = linkColor
        self.codeBackgroundColor = codeBackgroundColor
        self.blockquoteBackgroundColor = blockquoteBackgroundColor
        self.blockquoteIndicatorColor = blockquoteIndicatorColor
        self.lineSpacing = lineSpacing
        self.paragraphSpacing = paragraphSpacing
    }
    
    /// Create a dark mode variant of the theme
    public static var darkMode: MarkdownTheme {
        MarkdownTheme(
            textColor: .white,
            linkColor: .systemBlue,
            codeBackgroundColor: UIColor(white: 0.2, alpha: 1.0),
            blockquoteBackgroundColor: UIColor(white: 0.2, alpha: 1.0)
        )
    }
    
    /// Create a light mode variant of the theme
    public static var lightMode: MarkdownTheme {
        MarkdownTheme()
    }
}

/// A view that renders Markdown text with support for formatting and interactive elements
public final class MarkdownRendererView: UIView {
    
    // MARK: - Public Properties
    
    /// The delegate that will respond to user interactions with the rendered markdown
    public weak var delegate: MarkdownRendererViewDelegate?
    
    /// The current theme for the markdown renderer
    public var theme: MarkdownTheme {
        didSet {
            applyTheme()
            if let markdown = currentMarkdown {
                render(markdown: markdown)
            }
        }
    }
    
    // MARK: - Private Properties
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isEditable = false
        textView.isScrollEnabled = true
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return textView
    }()
    
    private var currentMarkdown: String?
    
    // MARK: - Initialization
    
    /// Initialize with a theme
    public init(theme: MarkdownTheme = MarkdownTheme()) {
        self.theme = theme
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        self.theme = MarkdownTheme()
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - Public Methods
    
    /// Render markdown text
    public func render(markdown: String) {
        currentMarkdown = markdown
        
        // Process basic sections of the markdown
        let components = processMarkdownComponents(markdown)
        let attributedText = NSMutableAttributedString()
        
        // Build attributed string from components
        for component in components {
            let formattedComponent = formatComponent(component)
            attributedText.append(formattedComponent)
        }
        
        textView.attributedText = attributedText
    }
    
    /// Set a new theme
    public func setTheme(_ theme: MarkdownTheme) {
        self.theme = theme
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        textView.delegate = self
        applyTheme()
    }
    
    private func applyTheme() {
        backgroundColor = .clear
        textView.textColor = theme.textColor
        textView.font = theme.font
    }
    
    /// Process markdown into components
    private func processMarkdownComponents(_ markdown: String) -> [MarkdownComponent] {
        var components: [MarkdownComponent] = []
        
        // Split markdown by lines for easier processing
        let lines = markdown.components(separatedBy: .newlines)
        var currentCodeBlock: String?
        var codeLanguage: String?
        var inCodeBlock = false
        var currentParagraph = ""
        
        func addCurrentParagraph() {
            if !currentParagraph.isEmpty {
                components.append(.paragraph(text: currentParagraph.trimmingCharacters(in: .whitespacesAndNewlines)))
                currentParagraph = ""
            }
        }
        
        for line in lines {
            // Handle code blocks
            if line.hasPrefix("```") {
                if inCodeBlock {
                    // End of code block
                    if let code = currentCodeBlock {
                        components.append(.codeBlock(code: code, language: codeLanguage ?? "plaintext"))
                    }
                    inCodeBlock = false
                    currentCodeBlock = nil
                    codeLanguage = nil
                } else {
                    // Start of code block
                    addCurrentParagraph()
                    inCodeBlock = true
                    currentCodeBlock = ""
                    
                    // Try to extract language
                    let languagePart = line.dropFirst(3)
                    if !languagePart.isEmpty {
                        codeLanguage = String(languagePart.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                }
                continue
            }
            
            if inCodeBlock {
                // Add line to current code block
                currentCodeBlock = (currentCodeBlock ?? "") + line + "\n"
                continue
            }
            
            // Handle headings (# Heading)
            if let headingLevel = getHeadingLevel(line) {
                addCurrentParagraph()
                let headingText = line.dropFirst(headingLevel + 1).trimmingCharacters(in: .whitespaces)
                components.append(.heading(level: headingLevel, text: headingText))
                continue
            }
            
            // Handle unordered lists (* Item)
            if line.trimmingCharacters(in: .whitespaces).matches(pattern: "^[*\\-+]\\s+.+$") {
                addCurrentParagraph()
                let itemText = line.trimmingCharacters(in: .whitespaces)
                    .replacingOccurrences(of: "^[*\\-+]\\s+", with: "", options: .regularExpression)
                components.append(.unorderedListItem(text: itemText))
                continue
            }
            
            // Handle ordered lists (1. Item)
            if line.trimmingCharacters(in: .whitespaces).matches(pattern: "^\\d+\\.\\s+.+$") {
                addCurrentParagraph()
                let itemText = line.trimmingCharacters(in: .whitespaces)
                    .replacingOccurrences(of: "^\\d+\\.\\s+", with: "", options: .regularExpression)
                let numberText = line.trimmingCharacters(in: .whitespaces)
                    .replacingOccurrences(of: "^(\\d+).*$", with: "$1", options: .regularExpression)
                components.append(.orderedListItem(number: numberText, text: itemText))
                continue
            }
            
            // Handle blockquotes (> Text)
            if line.trimmingCharacters(in: .whitespaces).hasPrefix(">") {
                addCurrentParagraph()
                let quoteText = line.trimmingCharacters(in: .whitespaces)
                    .replacingOccurrences(of: "^>\\s*", with: "", options: .regularExpression)
                components.append(.blockquote(text: quoteText))
                continue
            }
            
            // Handle empty lines as paragraph breaks
            if line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                addCurrentParagraph()
                continue
            }
            
            // Accumulate paragraph text
            if !currentParagraph.isEmpty {
                currentParagraph += " "
            }
            currentParagraph += line
        }
        
        // Add any remaining paragraph
        addCurrentParagraph()
        
        // Add any unclosed code block
        if inCodeBlock, let code = currentCodeBlock {
            components.append(.codeBlock(code: code, language: codeLanguage ?? "plaintext"))
        }
        
        return components
    }
    
    /// Format a markdown component into attributed string
    private func formatComponent(_ component: MarkdownComponent) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        // Create default paragraph style
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = theme.lineSpacing
        paragraphStyle.paragraphSpacing = theme.paragraphSpacing
        
        // Common attributes
        let baseAttributes: [NSAttributedString.Key: Any] = [
            .font: theme.font,
            .foregroundColor: theme.textColor,
            .paragraphStyle: paragraphStyle
        ]
        
        switch component {
        case .paragraph(let text):
            let attributedText = NSMutableAttributedString(string: text, attributes: baseAttributes)
            formatInlineElements(attributedText)
            result.append(attributedText)
            result.append(NSAttributedString(string: "\n\n"))
            
        case .heading(let level, let text):
            let headingStyle = NSMutableParagraphStyle()
            headingStyle.paragraphSpacing = theme.paragraphSpacing * 1.5
            
            let headingAttributes: [NSAttributedString.Key: Any] = [
                .font: theme.headingFonts[min(level - 1, theme.headingFonts.count - 1)],
                .foregroundColor: theme.textColor,
                .paragraphStyle: headingStyle
            ]
            
            let attributedText = NSMutableAttributedString(string: text, attributes: headingAttributes)
            formatInlineElements(attributedText)
            result.append(attributedText)
            result.append(NSAttributedString(string: "\n\n"))
            
        case .unorderedListItem(let text):
            let listStyle = NSMutableParagraphStyle()
            listStyle.headIndent = 20
            listStyle.firstLineHeadIndent = 0
            listStyle.tabStops = [NSTextTab(textAlignment: .left, location: 20)]
            
            let attributedText = NSMutableAttributedString(string: "• \t", attributes: baseAttributes)
            attributedText.addAttribute(.paragraphStyle, value: listStyle, range: NSRange(location: 0, length: attributedText.length))
            
            let itemText = NSMutableAttributedString(string: text, attributes: baseAttributes)
            formatInlineElements(itemText)
            attributedText.append(itemText)
            attributedText.append(NSAttributedString(string: "\n"))
            
            result.append(attributedText)
            
        case .orderedListItem(let number, let text):
            let listStyle = NSMutableParagraphStyle()
            listStyle.headIndent = 20
            listStyle.firstLineHeadIndent = 0
            listStyle.tabStops = [NSTextTab(textAlignment: .left, location: 20)]
            
            let attributedText = NSMutableAttributedString(string: "\(number). \t", attributes: baseAttributes)
            attributedText.addAttribute(.paragraphStyle, value: listStyle, range: NSRange(location: 0, length: attributedText.length))
            
            let itemText = NSMutableAttributedString(string: text, attributes: baseAttributes)
            formatInlineElements(itemText)
            attributedText.append(itemText)
            attributedText.append(NSAttributedString(string: "\n"))
            
            result.append(attributedText)
            
        case .blockquote(let text):
            let quoteStyle = NSMutableParagraphStyle()
            quoteStyle.headIndent = 20
            quoteStyle.firstLineHeadIndent = 20
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: theme.font,
                .foregroundColor: theme.textColor,
                .paragraphStyle: quoteStyle,
                .backgroundColor: theme.blockquoteBackgroundColor.withAlphaComponent(0.3)
            ]
            
            // Create a border view effect using a text attachment
            let borderAttachment = NSTextAttachment()
            borderAttachment.bounds = CGRect(x: 0, y: -2, width: 3, height: 20)
            
            // Create a colored image for the border
            let borderImage = UIImage.createSolidImage(
                color: theme.blockquoteIndicatorColor,
                size: CGSize(width: 3, height: 20)
            )
            borderAttachment.image = borderImage
            
            let attributedText = NSMutableAttributedString(attachment: borderAttachment)
            attributedText.append(NSAttributedString(string: " " + text, attributes: attributes))
            formatInlineElements(attributedText)
            attributedText.append(NSAttributedString(string: "\n\n"))
            
            result.append(attributedText)
            
        case .codeBlock(let code, let language):
            let codeStyle = NSMutableParagraphStyle()
            codeStyle.firstLineHeadIndent = 10
            codeStyle.headIndent = 10
            codeStyle.tailIndent = -10
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: theme.codeFont,
                .foregroundColor: theme.textColor,
                .paragraphStyle: codeStyle,
                .backgroundColor: theme.codeBackgroundColor
            ]
            
            // Add a language tag if available
            var codeBlockText = ""
            if !language.isEmpty && language != "plaintext" {
                codeBlockText += "[\(language)]\n"
            }
            codeBlockText += code
            
            let attributedCode = NSAttributedString(string: codeBlockText, attributes: attributes)
            
            // Create a container for the code block with rounded corners
            let container = NSMutableAttributedString()
            container.append(NSAttributedString(string: "\n"))
            container.append(attributedCode)
            container.append(NSAttributedString(string: "\n\n"))
            
            // Add a custom attribute for code blocks that we can use to detect taps
            container.addAttribute(.link, value: "code://\(language)/\(code.hashValue)", range: NSRange(location: 0, length: container.length))
            
            result.append(container)
        }
        
        return result
    }
    
    /// Format inline elements (bold, italic, code, links)
    private func formatInlineElements(_ attributedString: NSMutableAttributedString) {
        let text = attributedString.string
        
        // Bold (**text**)
        formatBoldText(attributedString, in: text)
        
        // Italic (*text*)
        formatItalicText(attributedString, in: text)
        
        // Inline code (`code`)
        formatInlineCode(attributedString, in: text)
        
        // Links ([title](url))
        formatLinks(attributedString, in: text)
    }
    
    /// Format bold text (**text**)
    private func formatBoldText(_ attributedString: NSMutableAttributedString, in text: String) {
        let pattern = "\\*\\*(.+?)\\*\\*"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        if let matches = regex?.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) {
            for match in matches.reversed() {
                if match.numberOfRanges >= 2 {
                    let boldRange = match.range(at: 0)
                    let contentRange = match.range(at: 1)
                    
                    // Replace the full match with just the content
                    let contentText = (text as NSString).substring(with: contentRange)
                    attributedString.replaceCharacters(in: boldRange, with: contentText)
                    
                    // Apply bold formatting
                    attributedString.addAttribute(.font, value: theme.boldFont, range: NSRange(location: boldRange.location, length: contentText.count))
                }
            }
        }
    }
    
    /// Format italic text (*text*)
    private func formatItalicText(_ attributedString: NSMutableAttributedString, in text: String) {
        let pattern = "\\*([^\\*]+)\\*"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        if let matches = regex?.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) {
            for match in matches.reversed() {
                if match.numberOfRanges >= 2 {
                    let italicRange = match.range(at: 0)
                    let contentRange = match.range(at: 1)
                    
                    // Replace the full match with just the content
                    let contentText = (text as NSString).substring(with: contentRange)
                    attributedString.replaceCharacters(in: italicRange, with: contentText)
                    
                    // Apply italic formatting
                    attributedString.addAttribute(.font, value: theme.italicFont, range: NSRange(location: italicRange.location, length: contentText.count))
                }
            }
        }
    }
    
    /// Format inline code (`code`)
    private func formatInlineCode(_ attributedString: NSMutableAttributedString, in text: String) {
        let pattern = "`([^`]+)`"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        if let matches = regex?.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) {
            for match in matches.reversed() {
                if match.numberOfRanges >= 2 {
                    let codeRange = match.range(at: 0)
                    let contentRange = match.range(at: 1)
                    
                    // Replace the full match with just the content
                    let contentText = (text as NSString).substring(with: contentRange)
                    attributedString.replaceCharacters(in: codeRange, with: contentText)
                    
                    // Apply code formatting
                    let inlineCodeRange = NSRange(location: codeRange.location, length: contentText.count)
                    attributedString.addAttribute(.font, value: theme.codeFont, range: inlineCodeRange)
                    attributedString.addAttribute(.backgroundColor, value: theme.codeBackgroundColor.withAlphaComponent(0.5), range: inlineCodeRange)
                }
            }
        }
    }
    
    /// Format links ([title](url))
    private func formatLinks(_ attributedString: NSMutableAttributedString, in text: String) {
        let pattern = "\\[([^\\]]+)\\]\\(([^\\)]+)\\)"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        if let matches = regex?.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) {
            for match in matches.reversed() {
                if match.numberOfRanges >= 3 {
                    let linkRange = match.range(at: 0)
                    let titleRange = match.range(at: 1)
                    let urlRange = match.range(at: 2)
                    
                    let title = (text as NSString).substring(with: titleRange)
                    let urlString = (text as NSString).substring(with: urlRange)
                    
                    // Replace the full match with just the title
                    attributedString.replaceCharacters(in: linkRange, with: title)
                    
                    // Apply link formatting
                    let titleLinkRange = NSRange(location: linkRange.location, length: title.count)
                    attributedString.addAttribute(.foregroundColor, value: theme.linkColor, range: titleLinkRange)
                    attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: titleLinkRange)
                    
                    if let url = URL(string: urlString) {
                        attributedString.addAttribute(.link, value: url, range: titleLinkRange)
                    }
                }
            }
        }
    }
    
    /// Get heading level from line (# = 1, ## = 2, etc.)
    private func getHeadingLevel(_ line: String) -> Int? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard trimmed.hasPrefix("#") else { return nil }
        
        var level = 0
        for char in trimmed {
            if char == "#" {
                level += 1
            } else {
                break
            }
        }
        
        // Ensure there's a space after the #'s and content after that
        guard level > 0,
              level <= 6,
              trimmed.count > level,
              trimmed[trimmed.index(trimmed.startIndex, offsetBy: level)] == " " else {
            return nil
        }
        
        return level
    }
    
    /// Create a colored image
    private func createColorImage(color: UIColor, size: CGSize) -> UIImage {
        return UIImage.createSolidImage(color: color, size: size)
    }
}

// MARK: - UITextViewDelegate

extension MarkdownRendererView: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        // Handle code blocks (using custom URL scheme)
        if URL.scheme == "code" {
            let components = URL.absoluteString.components(separatedBy: "/")
            if components.count >= 3 {
                let language = components[1]
                if let code = currentMarkdown?.ranges(of: "```", options: .regularExpression)
                    .chunked(into: 2)
                    .compactMap({ chunk -> String? in
                        guard chunk.count == 2 else { return nil }
                        let start = chunk[0].upperBound
                        let end = chunk[1].lowerBound
                        return String(currentMarkdown![start..<end])
                    })
                    .first {
                    delegate?.markdownRendererView(self, didTapCodeBlock: code, language: language)
                    return false
                }
            }
        }
        
        // Handle regular URLs
        delegate?.markdownRendererView(self, didTapLink: URL)
        return false
    }
}

// MARK: - Markdown Component Types

private enum MarkdownComponent {
    case paragraph(text: String)
    case heading(level: Int, text: String)
    case unorderedListItem(text: String)
    case orderedListItem(number: String, text: String)
    case blockquote(text: String)
    case codeBlock(code: String, language: String)
}

// MARK: - Helper Extensions

private extension String {
    func matches(pattern: String) -> Bool {
        return range(of: pattern, options: .regularExpression) != nil
    }
    
    func ranges(of string: String, options: CompareOptions = []) -> [Range<String.Index>] {
        var ranges: [Range<String.Index>] = []
        var start = startIndex
        
        while let range = range(of: string, options: options, range: start..<endIndex) {
            ranges.append(range)
            start = range.upperBound
        }
        
        return ranges
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

private extension UIImage {
    static func createSolidImage(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
} 