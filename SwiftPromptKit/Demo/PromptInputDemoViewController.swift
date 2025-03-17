import UIKit

/// A demo view controller that demonstrates the usage of the PromptInputView
final class PromptInputDemoViewController: UIViewController {
    
    // MARK: - Properties
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let promptInputView = PromptInputView()
    private let chatContainerView = UIView()
    private let controlsContainerView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 24)
        label.text = "PromptInputView Demo"
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.text = "A user-friendly input component that supports text entry, placeholder hints, send actions, and input validation."
        label.numberOfLines = 0
        return label
    }()
    
    private let messagesContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let messagesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        label.text = "Messages will appear here"
        label.numberOfLines = 0
        return label
    }()
    
    private let controlsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 18)
        label.text = "Component Controls"
        return label
    }()
    
    private let loadingSwitch = UISwitch()
    private let loadingSwitchLabel = UILabel()
    
    private let clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Clear Messages", for: .normal)
        button.backgroundColor = .systemGray5
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let placeholderTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.placeholder = "Custom placeholder text"
        return textField
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Placeholder Text:"
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private let applyPlaceholderButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Apply", for: .normal)
        return button
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "PromptInputView"
        
        setupScrollView()
        setupSubviews()
        setupPromptInputView()
        setupControls()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        let contentViewHeight = contentView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor)
        contentViewHeight.priority = .defaultLow
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentViewHeight
        ])
    }
    
    private func setupSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        
        // Chat container setup
        chatContainerView.translatesAutoresizingMaskIntoConstraints = false
        chatContainerView.backgroundColor = .systemBackground
        contentView.addSubview(chatContainerView)
        
        chatContainerView.addSubview(messagesContainer)
        messagesContainer.addSubview(messagesLabel)
        
        // Controls container setup
        controlsContainerView.translatesAutoresizingMaskIntoConstraints = false
        controlsContainerView.backgroundColor = .systemGray6
        controlsContainerView.layer.cornerRadius = 12
        contentView.addSubview(controlsContainerView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            chatContainerView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            chatContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            chatContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            messagesContainer.topAnchor.constraint(equalTo: chatContainerView.topAnchor, constant: 16),
            messagesContainer.leadingAnchor.constraint(equalTo: chatContainerView.leadingAnchor, constant: 20),
            messagesContainer.trailingAnchor.constraint(equalTo: chatContainerView.trailingAnchor, constant: -20),
            messagesContainer.bottomAnchor.constraint(equalTo: chatContainerView.bottomAnchor, constant: -16),
            messagesContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),
            
            messagesLabel.topAnchor.constraint(equalTo: messagesContainer.topAnchor, constant: 16),
            messagesLabel.leadingAnchor.constraint(equalTo: messagesContainer.leadingAnchor, constant: 16),
            messagesLabel.trailingAnchor.constraint(equalTo: messagesContainer.trailingAnchor, constant: -16),
            messagesLabel.bottomAnchor.constraint(equalTo: messagesContainer.bottomAnchor, constant: -16),
            
            controlsContainerView.topAnchor.constraint(equalTo: chatContainerView.bottomAnchor, constant: 20),
            controlsContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            controlsContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            controlsContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -100)
        ])
    }
    
    private func setupPromptInputView() {
        promptInputView.translatesAutoresizingMaskIntoConstraints = false
        promptInputView.delegate = self
        promptInputView.placeholder = "Ask me anything..."
        promptInputView.maxHeight = 120
        
        // Add custom action buttons
        let attachmentImage = UIImage(systemName: "paperclip")!
        promptInputView.addActionButton(
            image: attachmentImage,
            accessibilityLabel: "Attach file",
            tooltip: "Attach a file",
            action: { [weak self] in
                self?.showToast(message: "Attachment button tapped")
            }
        )
        
        let microphoneImage = UIImage(systemName: "mic")!
        promptInputView.addActionButton(
            image: microphoneImage,
            accessibilityLabel: "Voice input",
            tooltip: "Record voice",
            action: { [weak self] in
                self?.showToast(message: "Microphone button tapped")
            }
        )
        
        view.addSubview(promptInputView)
        
        NSLayoutConstraint.activate([
            promptInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            promptInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            promptInputView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -16)
        ])
    }
    
    private func setupControls() {
        controlsContainerView.addSubview(controlsLabel)
        
        // Loading switch
        loadingSwitch.translatesAutoresizingMaskIntoConstraints = false
        loadingSwitch.addTarget(self, action: #selector(loadingSwitchChanged), for: .valueChanged)
        
        loadingSwitchLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingSwitchLabel.text = "Loading State:"
        loadingSwitchLabel.font = .systemFont(ofSize: 16)
        
        controlsContainerView.addSubview(loadingSwitchLabel)
        controlsContainerView.addSubview(loadingSwitch)
        
        // Clear button
        clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        controlsContainerView.addSubview(clearButton)
        
        // Placeholder controls
        controlsContainerView.addSubview(placeholderLabel)
        controlsContainerView.addSubview(placeholderTextField)
        controlsContainerView.addSubview(applyPlaceholderButton)
        
        applyPlaceholderButton.addTarget(self, action: #selector(applyPlaceholderTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            controlsLabel.topAnchor.constraint(equalTo: controlsContainerView.topAnchor, constant: 16),
            controlsLabel.leadingAnchor.constraint(equalTo: controlsContainerView.leadingAnchor, constant: 16),
            controlsLabel.trailingAnchor.constraint(equalTo: controlsContainerView.trailingAnchor, constant: -16),
            
            loadingSwitchLabel.topAnchor.constraint(equalTo: controlsLabel.bottomAnchor, constant: 20),
            loadingSwitchLabel.leadingAnchor.constraint(equalTo: controlsContainerView.leadingAnchor, constant: 16),
            
            loadingSwitch.centerYAnchor.constraint(equalTo: loadingSwitchLabel.centerYAnchor),
            loadingSwitch.leadingAnchor.constraint(equalTo: loadingSwitchLabel.trailingAnchor, constant: 16),
            
            placeholderLabel.topAnchor.constraint(equalTo: loadingSwitchLabel.bottomAnchor, constant: 20),
            placeholderLabel.leadingAnchor.constraint(equalTo: controlsContainerView.leadingAnchor, constant: 16),
            
            placeholderTextField.topAnchor.constraint(equalTo: placeholderLabel.bottomAnchor, constant: 8),
            placeholderTextField.leadingAnchor.constraint(equalTo: controlsContainerView.leadingAnchor, constant: 16),
            placeholderTextField.trailingAnchor.constraint(equalTo: controlsContainerView.trailingAnchor, constant: -100),
            
            applyPlaceholderButton.centerYAnchor.constraint(equalTo: placeholderTextField.centerYAnchor),
            applyPlaceholderButton.leadingAnchor.constraint(equalTo: placeholderTextField.trailingAnchor, constant: 8),
            applyPlaceholderButton.trailingAnchor.constraint(equalTo: controlsContainerView.trailingAnchor, constant: -16),
            
            clearButton.topAnchor.constraint(equalTo: placeholderTextField.bottomAnchor, constant: 24),
            clearButton.centerXAnchor.constraint(equalTo: controlsContainerView.centerXAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 200),
            clearButton.heightAnchor.constraint(equalToConstant: 44),
            clearButton.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor, constant: -16)
        ])
    }
    
    @objc private func loadingSwitchChanged() {
        promptInputView.isLoading = loadingSwitch.isOn
        showToast(message: "Loading state set to \(loadingSwitch.isOn)")
    }
    
    @objc private func clearButtonTapped() {
        messagesLabel.text = "Messages will appear here"
        showToast(message: "Messages cleared")
    }
    
    @objc private func applyPlaceholderTapped() {
        if let text = placeholderTextField.text, !text.isEmpty {
            promptInputView.placeholder = text
            showToast(message: "Placeholder updated")
        } else {
            showToast(message: "Please enter placeholder text")
        }
    }
    
    private func simulateAIResponse(to message: String) {
        // Show loading state
        promptInputView.isLoading = true
        loadingSwitch.setOn(true, animated: true)
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            // Generate a simple response
            let response = "You said: \(message)"
            
            // Update UI
            self.messagesLabel.text = (self.messagesLabel.text == "Messages will appear here" ? "" : self.messagesLabel.text! + "\n\n") + "User: \(message)\nAI: \(response)"
            
            // End loading state
            self.promptInputView.isLoading = false
            self.loadingSwitch.setOn(false, animated: true)
            
            // Clear input text
            self.promptInputView.clearText()
        }
    }
    
    private func showToast(message: String) {
        let toast = UILabel()
        toast.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toast.textColor = .white
        toast.textAlignment = .center
        toast.font = .systemFont(ofSize: 14)
        toast.text = message
        toast.alpha = 0
        toast.layer.cornerRadius = 10
        toast.clipsToBounds = true
        toast.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(toast)
        
        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.bottomAnchor.constraint(equalTo: promptInputView.topAnchor, constant: -20),
            toast.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -40),
            toast.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])
        
        // Add padding
        toast.layoutMargins = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15)
        
        UIView.animate(withDuration: 0.3, animations: {
            toast.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 2, options: [], animations: {
                toast.alpha = 0
            }, completion: { _ in
                toast.removeFromSuperview()
            })
        })
    }
}

// MARK: - PromptInputViewDelegate

extension PromptInputDemoViewController: PromptInputViewDelegate {
    func promptInputView(_ inputView: PromptInputView, didSubmitText text: String) {
        simulateAIResponse(to: text)
    }
    
    func promptInputView(_ inputView: PromptInputView, didChangeText text: String) {
        // You can handle text changes here if needed
        // For example, you might want to show typing indicators
    }
} 