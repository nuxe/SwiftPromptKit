import UIKit

class MarkdownRendererViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let markdownRendererView: MarkdownRendererView = {
        let view = MarkdownRendererView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let themeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Toggle Dark Mode", for: .normal)
        return button
    }()
    
    private let sampleMarkdown = """
    # Markdown Example
    
    This is a **bold text** and this is an *italic text*.
    
    ## Lists
    
    ### Unordered List
    
    * Item 1
    * Item 2
    * Item 3
    
    ### Ordered List
    
    1. First item
    2. Second item
    3. Third item
    
    ## Links and Images
    
    [Visit Prompt Kit](https://www.prompt-kit.com)
    
    ## Code
    
    Inline `code example`.
    
    ```
    // Code block example
    function greet(name) {
      return `Hello, ${name}!`;
    }
    ```
    
    ## Blockquotes
    
    > This is a custom styled blockquote with multiple lines of text.
    > Second line of the blockquote.
    
    ## Custom Components
    
    This markdown renderer supports all common markdown formatting elements and can be easily customized with different themes.
    """
    
    private var isDarkMode = false
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        configureMarkdownRenderer()
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        title = "Markdown Renderer"
        view.backgroundColor = .systemBackground
        
        view.addSubview(markdownRendererView)
        view.addSubview(themeButton)
        
        NSLayoutConstraint.activate([
            themeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            themeButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            markdownRendererView.topAnchor.constraint(equalTo: themeButton.bottomAnchor, constant: 16),
            markdownRendererView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            markdownRendererView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            markdownRendererView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        themeButton.addTarget(self, action: #selector(toggleTheme), for: .touchUpInside)
    }
    
    private func configureMarkdownRenderer() {
        markdownRendererView.delegate = self
        markdownRendererView.render(markdown: sampleMarkdown)
    }
    
    @objc private func toggleTheme() {
        isDarkMode.toggle()
        
        if isDarkMode {
            markdownRendererView.setTheme(.darkMode)
            view.backgroundColor = .systemBackground
        } else {
            markdownRendererView.setTheme(.lightMode)
            view.backgroundColor = .systemBackground
        }
    }
}

// MARK: - MarkdownRendererViewDelegate

extension MarkdownRendererViewController: MarkdownRendererViewDelegate {
    func markdownRendererView(_ rendererView: MarkdownRendererView, didTapLink url: URL) {
        let alert = UIAlertController(title: "Link Tapped", message: "Would you like to open \(url)?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Open", style: .default, handler: { _ in
            UIApplication.shared.open(url)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    func markdownRendererView(_ rendererView: MarkdownRendererView, didTapCodeBlock code: String, language: String) {
        let alert = UIAlertController(title: "Code Block Tapped", message: "Code in \(language):\n\(code)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Copy", style: .default, handler: { _ in
            UIPasteboard.general.string = code
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
} 