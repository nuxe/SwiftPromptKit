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
            font: .systemFont(ofSize: 16),
            boldFont: .boldSystemFont(ofSize: 16),
            italicFont: .italicSystemFont(ofSize: 16),
            codeFont: .monospacedSystemFont(ofSize: 14, weight: .regular),
            headingFonts: [
                .boldSystemFont(ofSize: 24),
                .boldSystemFont(ofSize: 22),
                .boldSystemFont(ofSize: 20),
                .boldSystemFont(ofSize: 18),
                .boldSystemFont(ofSize: 16),
                .boldSystemFont(ofSize: 14)
            ],
            textColor: .white,
            linkColor: .systemBlue,
            codeBackgroundColor: UIColor(white: 0.2, alpha: 1.0),
            blockquoteBackgroundColor: UIColor(white: 0.2, alpha: 1.0),
            blockquoteIndicatorColor: .systemGreen,
            lineSpacing: 4.0,
            paragraphSpacing: 8.0
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
            // Process text for markdown patterns before creating the attributed string
            let processedText = processParagraphFormatting(text)
            result.append(processedText)
            result.append(NSAttributedString(string: "\n\n"))
            
        case .heading(let level, let text):
            let headingStyle = NSMutableParagraphStyle()
            headingStyle.paragraphSpacing = theme.paragraphSpacing * 1.5
            
            let headingAttributes: [NSAttributedString.Key: Any] = [
                .font: theme.headingFonts[min(level - 1, theme.headingFonts.count - 1)],
                .foregroundColor: theme.textColor,
                .paragraphStyle: headingStyle
            ]
            
            // Process heading text for markdown patterns
            let headingText = NSAttributedString(string: text, attributes: headingAttributes)
            result.append(headingText)
            result.append(NSAttributedString(string: "\n\n"))
            
        case .unorderedListItem(let text):
            let listStyle = NSMutableParagraphStyle()
            listStyle.headIndent = 20
            listStyle.firstLineHeadIndent = 0
            listStyle.tabStops = [NSTextTab(textAlignment: .left, location: 20)]
            
            let attributedText = NSMutableAttributedString(string: "• \t", attributes: baseAttributes)
            attributedText.addAttribute(.paragraphStyle, value: listStyle, range: NSRange(location: 0, length: attributedText.length))
            
            // Process the list item text for markdown patterns
            let itemText = processParagraphFormatting(text)
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
            
            // Process the list item text for markdown patterns
            let itemText = processParagraphFormatting(text)
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
            
            // Process the blockquote text for markdown patterns
            let processedText = processParagraphFormatting(text)
            
            // Add the formatted text with space
            let spacer = NSAttributedString(string: " ", attributes: attributes)
            attributedText.append(spacer)
            attributedText.append(processedText)
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
    
    /// Process paragraph text to handle markdown formatting more reliably
    private func processParagraphFormatting(_ text: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString()
        
        // First, process the text to identify markdown patterns
        var currentIndex = 0
        var plainTextStart = 0
        
        // Process the text character by character
        while currentIndex < text.count {
            // Bold text: **text**
            if let boldRange = findMarkdownPattern(in: text, startingAt: currentIndex, pattern: "**") {
                // Add any plain text before the bold text
                if plainTextStart < boldRange.startIndex {
                    let startIndex = text.index(text.startIndex, offsetBy: plainTextStart)
                    let endIndex = text.index(text.startIndex, offsetBy: boldRange.startIndex)
                    let plainText = text[startIndex..<endIndex]
                    let plainAttr = NSAttributedString(string: String(plainText), attributes: [
                        .font: theme.font,
                        .foregroundColor: theme.textColor
                    ])
                    attributedText.append(plainAttr)
                }
                
                // Add the bold text without the ** markers
                let boldStartIndex = text.index(text.startIndex, offsetBy: boldRange.startIndex + 2)
                let boldEndIndex = text.index(text.startIndex, offsetBy: boldRange.endIndex - 2)
                let boldText = text[boldStartIndex..<boldEndIndex]
                let boldAttr = NSAttributedString(string: String(boldText), attributes: [
                    .font: theme.boldFont,
                    .foregroundColor: theme.textColor
                ])
                attributedText.append(boldAttr)
                
                // Update indices
                plainTextStart = boldRange.endIndex
                currentIndex = boldRange.endIndex
                continue
            }
            
            // Italic text: *text*
            if let italicRange = findMarkdownPattern(in: text, startingAt: currentIndex, pattern: "*") {
                // Add any plain text before the italic text
                if plainTextStart < italicRange.startIndex {
                    let startIndex = text.index(text.startIndex, offsetBy: plainTextStart)
                    let endIndex = text.index(text.startIndex, offsetBy: italicRange.startIndex)
                    let plainText = text[startIndex..<endIndex]
                    let plainAttr = NSAttributedString(string: String(plainText), attributes: [
                        .font: theme.font,
                        .foregroundColor: theme.textColor
                    ])
                    attributedText.append(plainAttr)
                }
                
                // Add the italic text without the * markers
                let italicStartIndex = text.index(text.startIndex, offsetBy: italicRange.startIndex + 1)
                let italicEndIndex = text.index(text.startIndex, offsetBy: italicRange.endIndex - 1)
                let italicText = text[italicStartIndex..<italicEndIndex]
                let italicAttr = NSAttributedString(string: String(italicText), attributes: [
                    .font: theme.italicFont,
                    .foregroundColor: theme.textColor
                ])
                attributedText.append(italicAttr)
                
                // Update indices
                plainTextStart = italicRange.endIndex
                currentIndex = italicRange.endIndex
                continue
            }
            
            // Code: `text`
            if let codeRange = findMarkdownPattern(in: text, startingAt: currentIndex, pattern: "`") {
                // Add any plain text before the code
                if plainTextStart < codeRange.startIndex {
                    let startIndex = text.index(text.startIndex, offsetBy: plainTextStart)
                    let endIndex = text.index(text.startIndex, offsetBy: codeRange.startIndex)
                    let plainText = text[startIndex..<endIndex]
                    let plainAttr = NSAttributedString(string: String(plainText), attributes: [
                        .font: theme.font,
                        .foregroundColor: theme.textColor
                    ])
                    attributedText.append(plainAttr)
                }
                
                // Add the code without the ` markers
                let codeStartIndex = text.index(text.startIndex, offsetBy: codeRange.startIndex + 1)
                let codeEndIndex = text.index(text.startIndex, offsetBy: codeRange.endIndex - 1)
                let codeText = text[codeStartIndex..<codeEndIndex]
                let codeAttr = NSAttributedString(string: String(codeText), attributes: [
                    .font: theme.codeFont,
                    .foregroundColor: theme.textColor,
                    .backgroundColor: theme.codeBackgroundColor.withAlphaComponent(0.5)
                ])
                attributedText.append(codeAttr)
                
                // Update indices
                plainTextStart = codeRange.endIndex
                currentIndex = codeRange.endIndex
                continue
            }
            
            // Link: [text](url)
            if let linkMatch = findLinkPattern(in: text, startingAt: currentIndex) {
                // Add any plain text before the link
                if plainTextStart < linkMatch.fullRange.startIndex {
                    let startIndex = text.index(text.startIndex, offsetBy: plainTextStart)
                    let endIndex = text.index(text.startIndex, offsetBy: linkMatch.fullRange.startIndex)
                    let plainText = text[startIndex..<endIndex]
                    let plainAttr = NSAttributedString(string: String(plainText), attributes: [
                        .font: theme.font,
                        .foregroundColor: theme.textColor
                    ])
                    attributedText.append(plainAttr)
                }
                
                // Add the link text
                let linkAttr = NSMutableAttributedString(string: linkMatch.text, attributes: [
                    .font: theme.font,
                    .foregroundColor: theme.linkColor,
                    .underlineStyle: NSUnderlineStyle.single.rawValue
                ])
                
                if let url = URL(string: linkMatch.url) {
                    linkAttr.addAttribute(.link, value: url, range: NSRange(location: 0, length: linkMatch.text.count))
                }
                
                attributedText.append(linkAttr)
                
                // Update indices
                plainTextStart = linkMatch.fullRange.endIndex
                currentIndex = linkMatch.fullRange.endIndex
                continue
            }
            
            // Move to next character if no pattern found
            currentIndex += 1
        }
        
        // Add any remaining plain text
        if plainTextStart < text.count {
            let startIndex = text.index(text.startIndex, offsetBy: plainTextStart)
            let endIndex = text.index(text.startIndex, offsetBy: text.count)
            let plainText = text[startIndex..<endIndex]
            let plainAttr = NSAttributedString(string: String(plainText), attributes: [
                .font: theme.font,
                .foregroundColor: theme.textColor
            ])
            attributedText.append(plainAttr)
        }
        
        return attributedText
    }
    
    /// Find a markdown pattern in text (like ** for bold, * for italic, etc.)
    private func findMarkdownPattern(in text: String, startingAt index: Int, pattern: String) -> Range<Int>? {
        guard index < text.count, 
              let patternStart = text.indexOf(pattern, startingAt: index) else {
            return nil
        }
        
        // Find the end of the pattern (closing marker)
        let afterStart = patternStart + pattern.count
        if let patternEnd = text.indexOf(pattern, startingAt: afterStart) {
            return patternStart..<(patternEnd + pattern.count)
        }
        
        return nil
    }
    
    /// Find a link pattern [text](url) in text
    private func findLinkPattern(in text: String, startingAt index: Int) -> LinkMatch? {
        guard index < text.count else { return nil }
        
        // Find opening [
        let startIndexPos = text.index(text.startIndex, offsetBy: index)
        guard let textStart = text[startIndexPos...].firstIndex(of: "[") else { return nil }
        let textStartOffset = text.distance(from: text.startIndex, to: textStart)
        
        // Find closing ]
        guard let textEnd = text[textStart...].firstIndex(of: "]") else { return nil }
        
        // Check for opening (
        let nextIndex = text.index(after: textEnd)
        guard nextIndex < text.endIndex && text[nextIndex] == "(" else { return nil }
        
        // Find closing )
        guard let urlEnd = text[nextIndex...].firstIndex(of: ")") else { return nil }
        let urlEndOffset = text.distance(from: text.startIndex, to: urlEnd)
        
        // Extract text and URL
        let textRange = text.index(after: textStart)..<textEnd
        let urlRange = text.index(after: nextIndex)..<urlEnd
        
        // Return matched components
        return LinkMatch(
            text: String(text[textRange]),
            url: String(text[urlRange]),
            fullRange: textStartOffset..<(urlEndOffset + 1)
        )
    }
    
    /// Structure to hold link match results
    private struct LinkMatch {
        let text: String
        let url: String
        let fullRange: Range<Int>
    }
    
    /// Format inline elements (bold, italic, code, links)
    private func formatInlineElements(_ attributedString: NSMutableAttributedString) {
        let text = attributedString.string
        
        // Links first
        formatLinks(attributedString, in: text)
        
        // Inline code 
        formatInlineCode(attributedString, in: text)
        
        // Bold formatting
        formatBoldText(attributedString, in: text)
        
        // Italic formatting
        formatItalicText(attributedString, in: text)
    }
    
    /// Format bold text (**text**)
    private func formatBoldText(_ attributedString: NSMutableAttributedString, in text: String) {
        // Simple pattern: Match **text** format
        let pattern = "\\*\\*([^*]+)\\*\\*"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        guard let matches = regex?.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) else {
            return
        }
        
        for match in matches.reversed() {
            guard match.numberOfRanges >= 2 else { continue }
            
            let boldRange = match.range(at: 0)
            let contentRange = match.range(at: 1)
            
            if boldRange.location == NSNotFound || contentRange.location == NSNotFound {
                continue
            }
            
            // Safe check for valid ranges
            if boldRange.location + boldRange.length <= text.utf16.count && 
               contentRange.location + contentRange.length <= text.utf16.count {
                // Get the bold text without the ** markers
                let contentText = (text as NSString).substring(with: contentRange)
                
                // Replace the entire match with just the content
                attributedString.replaceCharacters(in: boldRange, with: contentText)
                
                // Apply bold formatting at the location where the replacement happened
                if boldRange.location < attributedString.length {
                    let formattingRange = NSRange(location: boldRange.location, length: min(contentText.count, attributedString.length - boldRange.location))
                    attributedString.addAttribute(.font, value: theme.boldFont, range: formattingRange)
                }
            }
        }
    }
    
    /// Format italic text (*text*)
    private func formatItalicText(_ attributedString: NSMutableAttributedString, in text: String) {
        // Simple pattern: Match *text* format
        let pattern = "\\*([^*]+)\\*"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        
        guard let matches = regex?.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) else {
            return
        }
        
        for match in matches.reversed() {
            guard match.numberOfRanges >= 2 else { continue }
            
            let italicRange = match.range(at: 0)
            let contentRange = match.range(at: 1)
            
            if italicRange.location == NSNotFound || contentRange.location == NSNotFound {
                continue
            }
            
            // Safe check for valid ranges
            if italicRange.location + italicRange.length <= text.utf16.count && 
               contentRange.location + contentRange.length <= text.utf16.count {
                // Get the italic text without the * markers
                let contentText = (text as NSString).substring(with: contentRange)
                
                // Replace the entire match with just the content
                attributedString.replaceCharacters(in: italicRange, with: contentText)
                
                // Apply italic formatting at the location where the replacement happened
                if italicRange.location < attributedString.length {
                    let formattingRange = NSRange(location: italicRange.location, length: min(contentText.count, attributedString.length - italicRange.location))
                    attributedString.addAttribute(.font, value: theme.italicFont, range: formattingRange)
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
    
    // Helper to find index of a substring
    func indexOf(_ substring: String, startingAt startIndex: Int) -> Int? {
        guard startIndex < count else { return nil }
        
        let start = index(self.startIndex, offsetBy: startIndex)
        if let range = self.range(of: substring, range: start..<self.endIndex) {
            return self.distance(from: self.startIndex, to: range.lowerBound)
        }
        return nil
    }
    
    // Helper to find the first index of a character after a given position
    func firstIndex(of character: Character, after position: Int) -> String.Index? {
        guard position < count else { return nil }
        
        let start = index(startIndex, offsetBy: position)
        return self[start...].firstIndex(of: character)
    }
    
    // Helper to find the first index of a character after a given index
    func firstIndex(of character: Character, after index: String.Index) -> String.Index? {
        guard index < endIndex else { return nil }
        
        let start = self.index(after: index)
        return self[start...].firstIndex(of: character)
    }
    
    // Subscript to get character at integer index
    subscript(position: Int) -> Character {
        return self[index(startIndex, offsetBy: position)]
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

// Extension to add support for component text and newline behavior
private extension MarkdownComponent {
    var text: String {
        switch self {
        case .paragraph(let text):
            return text
        case .heading(_, let text):
            return text
        case .unorderedListItem(let text):
            return "• \(text)"
        case .orderedListItem(let number, let text):
            return "\(number). \(text)"
        case .blockquote(let text):
            return "> \(text)"
        case .codeBlock(let code, _):
            return code
        }
    }
    
    var needsExtraNewline: Bool {
        switch self {
        case .paragraph, .heading, .blockquote, .codeBlock:
            return true
        case .unorderedListItem, .orderedListItem:
            return false
        }
    }
} 