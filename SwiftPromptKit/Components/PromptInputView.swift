import UIKit

/// A protocol that defines methods for the PromptInputView delegate
public protocol PromptInputViewDelegate: AnyObject {
    /// Called when the user submits text in the input view
    func promptInputView(_ inputView: PromptInputView, didSubmitText text: String)
    
    /// Called when the text in the input view changes
    func promptInputView(_ inputView: PromptInputView, didChangeText text: String)
}

/// A view that provides a user-friendly input component for text entry in chat interfaces
public final class PromptInputView: UIView {
    
    // MARK: - Public Properties
    
    /// The delegate that will respond to input events
    public weak var delegate: PromptInputViewDelegate?
    
    /// The current text in the input field
    public var text: String {
        get { textView.text }
        set {
            textView.text = newValue
            updateSendButtonState()
            updateTextViewHeight()
        }
    }
    
    /// The placeholder text to display when the input is empty
    public var placeholder: String? {
        get { placeholderLabel.text }
        set {
            placeholderLabel.text = newValue
            placeholderLabel.isHidden = !textView.text.isEmpty
        }
    }
    
    /// The maximum height the text view can expand to
    public var maxHeight: CGFloat = 120.0 {
        didSet {
            updateTextViewHeight()
        }
    }
    
    /// Whether the input view is in a loading state
    public var isLoading: Bool = false {
        didSet {
            sendButton.isEnabled = !isLoading && !textView.text.isEmpty
            loadingIndicator.isHidden = !isLoading
            sendButton.isHidden = isLoading
        }
    }
    
    /// Whether the input view is enabled
    public var isEnabled: Bool = true {
        didSet {
            textView.isEditable = isEnabled
            sendButton.isEnabled = isEnabled && !textView.text.isEmpty
        }
    }
    
    // MARK: - Private Properties
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 20.0
        view.layer.borderWidth = 1.0
        view.layer.borderColor = UIColor.systemGray5.cgColor
        return view
    }()
    
    private let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .systemFont(ofSize: 16)
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        return textView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        label.textColor = .systemGray3
        return label
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        let image = UIImage(systemName: "arrow.up.circle.fill", withConfiguration: configuration)
        button.setImage(image, for: .normal)
        button.tintColor = .systemBlue
        button.isEnabled = false
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.isHidden = true
        return indicator
    }()
    
    private let actionsContainerView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Public Methods
    
    /// Clears the text in the input field
    public func clearText() {
        textView.text = ""
        updateSendButtonState()
        updateTextViewHeight()
        placeholderLabel.isHidden = false
    }
    
    /// Adds an action button to the input view
    public func addActionButton(image: UIImage, accessibilityLabel: String, tooltip: String, action: @escaping () -> Void) {
        let button = createActionButton(image: image, accessibilityLabel: accessibilityLabel, action: action)
        actionsContainerView.addArrangedSubview(button)
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        backgroundColor = .clear
        
        addSubview(containerView)
        containerView.addSubview(textView)
        containerView.addSubview(placeholderLabel)
        containerView.addSubview(actionsContainerView)
        containerView.addSubview(sendButton)
        containerView.addSubview(loadingIndicator)
        
        textView.delegate = self
        
        setupConstraints()
        setupActions()
        
        // Start with placeholder visible
        placeholderLabel.isHidden = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            textView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
            textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            textView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            textView.bottomAnchor.constraint(equalTo: actionsContainerView.topAnchor, constant: -4),
            
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 12),
            placeholderLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: textView.centerYAnchor),
            
            actionsContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            actionsContainerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            actionsContainerView.heightAnchor.constraint(equalToConstant: 32),
            
            sendButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 32),
            sendButton.heightAnchor.constraint(equalToConstant: 32),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: sendButton.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor)
        ])
        
        // Set initial height constraint for textView
        updateTextViewHeight()
    }
    
    private func setupActions() {
        @objc func sendButtonTapped() {
            submitText()
        }
        
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
    }
    
    private func createActionButton(image: UIImage, accessibilityLabel: String, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(image, for: .normal)
        button.accessibilityLabel = accessibilityLabel
        button.tintColor = .systemGray
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 32),
            button.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        return button
    }
    
    private func updateSendButtonState() {
        sendButton.isEnabled = !isLoading && !textView.text.isEmpty && isEnabled
    }
    
    private func updateTextViewHeight() {
        // Calculate new height based on content
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        
        // Limit height to maxHeight
        let limitedHeight = min(newSize.height, maxHeight)
        
        // Update textView height constraint
        for constraint in textView.constraints where constraint.firstAttribute == .height {
            textView.removeConstraint(constraint)
        }
        
        // If textView needs to scroll, enable scrolling
        textView.isScrollEnabled = newSize.height > maxHeight
        
        // Add new height constraint
        textView.heightAnchor.constraint(equalToConstant: limitedHeight).isActive = true
        
        // Update layout
        layoutIfNeeded()
    }
    
    private func submitText() {
        guard !textView.text.isEmpty else { return }
        
        let textToSubmit = textView.text
        delegate?.promptInputView(self, didSubmitText: textToSubmit)
        
        // Don't clear text here to allow the delegate to decide whether to clear it
    }
}

// MARK: - UITextViewDelegate

extension PromptInputView: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        updateSendButtonState()
        updateTextViewHeight()
        placeholderLabel.isHidden = !textView.text.isEmpty
        delegate?.promptInputView(self, didChangeText: textView.text)
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Handle return key press to submit
        if text == "\n" && !textView.text.isEmpty && !(textView.text.last == "\n") {
            submitText()
            return false
        }
        return true
    }
} 
