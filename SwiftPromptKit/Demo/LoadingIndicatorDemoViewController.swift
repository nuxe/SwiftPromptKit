import UIKit

/// A view controller that demonstrates the LoadingIndicatorView with all available variants and options
final class LoadingIndicatorDemoViewController: UIViewController {
    
    // MARK: - Properties
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 32
        stackView.alignment = .center
        return stackView
    }()
    
    // Replace picker view with a dropdown button
    private let variantDropdownButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("circular", for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.backgroundColor = .tertiarySystemBackground
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        let chevronImage = UIImage(systemName: "chevron.down", withConfiguration: imageConfig)
        button.setImage(chevronImage, for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        return button
    }()
    
    private let variantOptions: [String] = [
        "circular", "classic", "pulse", "pulse-dot", 
        "dots", "typing", "wave", "bars", 
        "terminal", "text-blink", "text-shimmer", "loading-dots"
    ]
    
    private var selectedVariantIndex: Int = 0
    
    private let sizeControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Small", "Medium", "Large"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 1
        return control
    }()
    
    private let colorControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Blue", "Red", "Green", "Purple"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 0
        return control
    }()
    
    private let textSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.isOn = false
        return toggle
    }()
    
    private let animationSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.isOn = true
        return toggle
    }()
    
    private var loadingIndicatorView: LoadingIndicatorView!
    private var loadingContainerView: UIView!
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Custom text for loader"
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        createLoadingIndicator()
        loadingIndicatorView.startAnimating()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Loading Indicator Demo"
        
        setupScrollView()
        setupControls()
        setupLoadingContainer()
        setupActions()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }
    
    private func setupControls() {
        // Variant selector - use dropdown instead of picker
        let variantLabel = createLabel(text: "Loader Variant:")
        
        let variantButtonWrapper = createControlWrapper(for: variantDropdownButton)
        variantButtonWrapper.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // Size selector
        let sizeLabel = createLabel(text: "Size:")
        let sizeControlWrapper = createControlWrapper(for: sizeControl)
        
        // Color selector
        let colorLabel = createLabel(text: "Color:")
        let colorControlWrapper = createControlWrapper(for: colorControl)
        
        // Animation switch
        let animationLabel = createLabel(text: "Animation:")
        let animationSwitchWrapper = createSwitchWrapper(with: animationLabel, and: animationSwitch)
        
        // Text switch and field
        let textLabel = createLabel(text: "Show Text:")
        let textSwitchWrapper = createSwitchWrapper(with: textLabel, and: textSwitch)
        
        let textFieldWrapper = UIView()
        textFieldWrapper.translatesAutoresizingMaskIntoConstraints = false
        textFieldWrapper.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: textFieldWrapper.topAnchor),
            textField.leadingAnchor.constraint(equalTo: textFieldWrapper.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: textFieldWrapper.trailingAnchor),
            textField.bottomAnchor.constraint(equalTo: textFieldWrapper.bottomAnchor),
            textField.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Add all controls to stack view
        contentStackView.addArrangedSubview(variantLabel)
        contentStackView.addArrangedSubview(variantButtonWrapper)
        contentStackView.addArrangedSubview(sizeLabel)
        contentStackView.addArrangedSubview(sizeControlWrapper)
        contentStackView.addArrangedSubview(colorLabel)
        contentStackView.addArrangedSubview(colorControlWrapper)
        contentStackView.addArrangedSubview(animationSwitchWrapper)
        contentStackView.addArrangedSubview(textSwitchWrapper)
        contentStackView.addArrangedSubview(textFieldWrapper)
        
        // Add a separator
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = .separator
        contentStackView.addArrangedSubview(separatorView)
        NSLayoutConstraint.activate([
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.widthAnchor.constraint(equalTo: contentStackView.widthAnchor)
        ])
        
        // Configure the dropdown menu
        configureVariantDropdown()
    }
    
    private func setupLoadingContainer() {
        // Create a container for the loading indicator
        loadingContainerView = UIView()
        loadingContainerView.translatesAutoresizingMaskIntoConstraints = false
        loadingContainerView.backgroundColor = .secondarySystemBackground
        loadingContainerView.layer.cornerRadius = 16
        
        contentStackView.addArrangedSubview(loadingContainerView)
        NSLayoutConstraint.activate([
            loadingContainerView.heightAnchor.constraint(equalToConstant: 200),
            loadingContainerView.widthAnchor.constraint(equalTo: contentStackView.widthAnchor)
        ])
    }
    
    private func createLoadingIndicator() {
        // Create a new loader instance
        if loadingIndicatorView != nil {
            loadingIndicatorView.stopAnimating()
            loadingIndicatorView.removeFromSuperview()
        }
        
        loadingIndicatorView = LoadingIndicatorView(
            variant: getSelectedVariant(),
            size: getSelectedSize(),
            text: textSwitch.isOn ? (textField.text?.isEmpty == false ? textField.text : "Loading") : nil
        )
        loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicatorView.primaryColor = getSelectedColor()
        
        loadingContainerView.addSubview(loadingIndicatorView)
        
        NSLayoutConstraint.activate([
            loadingIndicatorView.centerXAnchor.constraint(equalTo: loadingContainerView.centerXAnchor),
            loadingIndicatorView.centerYAnchor.constraint(equalTo: loadingContainerView.centerYAnchor)
        ])
        
        if animationSwitch.isOn {
            loadingIndicatorView.startAnimating()
        }
    }
    
    private func setupActions() {
        sizeControl.addTarget(self, action: #selector(sizeChanged), for: .valueChanged)
        colorControl.addTarget(self, action: #selector(colorChanged), for: .valueChanged)
        textSwitch.addTarget(self, action: #selector(textSwitchChanged), for: .valueChanged)
        animationSwitch.addTarget(self, action: #selector(animationSwitchChanged), for: .valueChanged)
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func configureVariantDropdown() {
        var menuActions = [UIAction]()
        
        for (index, option) in variantOptions.enumerated() {
            let action = UIAction(title: option) { [weak self] _ in
                guard let self = self else { return }
                self.selectedVariantIndex = index
                self.variantDropdownButton.setTitle(option, for: .normal)
                self.updateVariant()
            }
            
            // Mark the currently selected variant
            if index == selectedVariantIndex {
                action.state = .on
            }
            
            menuActions.append(action)
        }
        
        variantDropdownButton.menu = UIMenu(title: "Select Variant", children: menuActions)
        variantDropdownButton.showsMenuAsPrimaryAction = true
    }
    
    // MARK: - Helper Methods
    
    private func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }
    
    private func createControlWrapper(for control: UIView, height: CGFloat = 44) -> UIView {
        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(control)
        
        NSLayoutConstraint.activate([
            control.topAnchor.constraint(equalTo: wrapper.topAnchor),
            control.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            control.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            control.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
            wrapper.heightAnchor.constraint(equalToConstant: height)
        ])
        
        return wrapper
    }
    
    private func createSwitchWrapper(with label: UILabel, and switchControl: UISwitch) -> UIView {
        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        
        wrapper.addSubview(label)
        wrapper.addSubview(switchControl)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: wrapper.centerYAnchor),
            
            switchControl.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            switchControl.centerYAnchor.constraint(equalTo: wrapper.centerYAnchor),
            
            wrapper.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return wrapper
    }
    
    private func getSelectedVariant() -> LoaderVariant {
        switch selectedVariantIndex {
        case 0: return .circular
        case 1: return .classic
        case 2: return .pulse
        case 3: return .pulseDot
        case 4: return .dots
        case 5: return .typing
        case 6: return .wave
        case 7: return .bars
        case 8: return .terminal
        case 9: return .textBlink
        case 10: return .textShimmer
        case 11: return .loadingDots
        default: return .circular
        }
    }
    
    private func getSelectedSize() -> LoaderSize {
        switch sizeControl.selectedSegmentIndex {
        case 0: return .small
        case 1: return .medium
        case 2: return .large
        default: return .medium
        }
    }
    
    private func getSelectedColor() -> UIColor {
        switch colorControl.selectedSegmentIndex {
        case 0: return .systemBlue
        case 1: return .systemRed
        case 2: return .systemGreen
        case 3: return .systemPurple
        default: return .systemBlue
        }
    }
    
    private func updateVariant() {
        let variant = getSelectedVariant()
        
        // Update the text switch state based on whether the selected variant supports text
        let isTextVariant = (variant == .textBlink || variant == .textShimmer || variant == .loadingDots)
        textSwitch.isEnabled = isTextVariant
        textField.isEnabled = isTextVariant && textSwitch.isOn
        
        if isTextVariant && !textSwitch.isOn {
            textSwitch.setOn(true, animated: true)
            textSwitchChanged()
        } else if !isTextVariant && textSwitch.isOn {
            textSwitch.setOn(false, animated: true)
            textSwitchChanged()
        }
        
        // Recreate the loading indicator
        createLoadingIndicator()
    }
    
    // MARK: - Action Methods
    
    @objc private func sizeChanged() {
        loadingIndicatorView.size = getSelectedSize()
    }
    
    @objc private func colorChanged() {
        loadingIndicatorView.primaryColor = getSelectedColor()
    }
    
    @objc private func textSwitchChanged() {
        let showText = textSwitch.isOn
        textField.isEnabled = showText
        
        if showText {
            loadingIndicatorView.text = textField.text?.isEmpty == false ? textField.text : "Loading"
        } else {
            loadingIndicatorView.text = nil
        }
    }
    
    @objc private func textFieldChanged() {
        if textSwitch.isOn {
            loadingIndicatorView.text = textField.text?.isEmpty == false ? textField.text : "Loading"
        }
    }
    
    @objc private func animationSwitchChanged() {
        if animationSwitch.isOn {
            loadingIndicatorView.startAnimating()
        } else {
            loadingIndicatorView.stopAnimating()
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
} 