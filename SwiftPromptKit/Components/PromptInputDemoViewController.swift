import UIKit

/// A demo view controller that demonstrates the usage of the PromptInputView
class PromptInputDemoViewController: UIViewController {
    
    // MARK: - Properties
    
    private let promptInputView = PromptInputView()
    private let messagesLabel = UILabel()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "PromptInputView Demo"
        
        setupMessagesLabel()
        setupPromptInputView()
    }
    
    private func setupMessagesLabel() {
        messagesLabel.translatesAutoresizingMaskIntoConstraints = false
        messagesLabel.font = .systemFont(ofSize: 16)
        messagesLabel.textColor = .label
        messagesLabel.numberOfLines = 0
        messagesLabel.text = "Messages will appear here"
        
        view.addSubview(messagesLabel)
        
        NSLayoutConstraint.activate([
            messagesLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            messagesLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            messagesLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
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
        toast.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
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
    
    private func simulateAIResponse(to message: String) {
        // Show loading state
        promptInputView.isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            // Generate a simple response
            let response = "You said: \(message)"
            
            // Update UI
            self.messagesLabel.text = (self.messagesLabel.text == "Messages will appear here" ? "" : self.messagesLabel.text! + "\n\n") + "User: \(message)\nAI: \(response)"
            
            // End loading state
            self.promptInputView.isLoading = false
            
            // Clear input text
            self.promptInputView.clearText()
        }
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