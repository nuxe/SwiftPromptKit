import UIKit

/// A view controller that demonstrates the LoadingIndicatorView with all available variants and options
final class LoadingIndicatorDemoViewController: UIViewController {
    
    // MARK: - Properties
    
    // Main container view
    private let mainContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Container for all controls
    private let controlsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Top section with variant dropdown
    private let variantDropdownButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("circular", for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.backgroundColor = .tertiarySystemBackground
        button.layer.cornerRadius = 6
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
        let chevronImage = UIImage(systemName: "chevron.down", withConfiguration: imageConfig)
        button.setImage(chevronImage, for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        return button
    }()
    
    private let variantLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Variant:"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    private let variantOptions: [String] = [
        "circular", "classic", "pulse", "pulse-dot", 
        "dots", "typing", "wave", "bars", 
        "terminal", "text-blink", "text-shimmer", "loading-dots"
    ]
    
    private var selectedVariantIndex: Int = 0
    
    // Middle section with controls in groups
    private let sizeControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["S", "M", "L"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 1
        return control
    }()
    
    private let sizeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Size:"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    private let colorDropdownButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("blue", for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.backgroundColor = .tertiarySystemBackground
        button.layer.cornerRadius = 6
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
        let chevronImage = UIImage(systemName: "chevron.down", withConfiguration: imageConfig)
        button.setImage(chevronImage, for: .normal)
        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        return button
    }()
    
    private let colorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Color:"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    private let colorOptions: [String] = ["blue", "red", "green", "purple", "black"]
    private var selectedColorIndex: Int = 0
    
    // Bottom section with switches and text field
    private let textSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.isOn = false
        toggle.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        return toggle
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Text:"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    private let animationSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.isOn = true
        toggle.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        return toggle
    }()
    
    private let animationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Animate:"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    private var loadingIndicatorView: LoadingIndicatorView!
    private var loadingContainerView: UIView!
    private var isUpdatingIndicator = false
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Custom text for loader"
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.font = .systemFont(ofSize: 15)
        return textField
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        createLoadingIndicator(startAnimating: false)
        
        // Delay animation start to prevent recursive calls
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            if self.animationSwitch.isOn {
                self.loadingIndicatorView.startAnimating()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Loading Indicator Demo"
        
        setupLayout()
        configureVariantDropdown()
        configureColorDropdown()
        setupActions()
    }
    
    private func setupLayout() {
        // Add main container to view
        view.addSubview(mainContainerView)
        
        // Add controls container and loading container to main container
        mainContainerView.addSubview(controlsContainerView)
        
        // Set up loadingContainerView
        loadingContainerView = UIView()
        loadingContainerView.translatesAutoresizingMaskIntoConstraints = false
        loadingContainerView.backgroundColor = .secondarySystemBackground
        loadingContainerView.layer.cornerRadius = 12
        mainContainerView.addSubview(loadingContainerView)
        
        // Main container constraints
        NSLayoutConstraint.activate([
            mainContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            mainContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mainContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        
        // Layout controls and loading containers
        NSLayoutConstraint.activate([
            controlsContainerView.topAnchor.constraint(equalTo: mainContainerView.topAnchor),
            controlsContainerView.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor),
            controlsContainerView.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor),
            
            loadingContainerView.topAnchor.constraint(equalTo: controlsContainerView.bottomAnchor, constant: 16),
            loadingContainerView.leadingAnchor.constraint(equalTo: mainContainerView.leadingAnchor),
            loadingContainerView.trailingAnchor.constraint(equalTo: mainContainerView.trailingAnchor),
            loadingContainerView.bottomAnchor.constraint(equalTo: mainContainerView.bottomAnchor),
            loadingContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 160)
        ])
        
        // Setup controls layout
        setupControlsLayout()
    }
    
    private func setupControlsLayout() {
        // Add variant selection (top row)
        controlsContainerView.addSubview(variantLabel)
        controlsContainerView.addSubview(variantDropdownButton)
        
        // Add color selection (second row)
        controlsContainerView.addSubview(colorLabel)
        controlsContainerView.addSubview(colorDropdownButton)
        
        // Add size controls (third row)
        controlsContainerView.addSubview(sizeLabel)
        controlsContainerView.addSubview(sizeControl)
        
        // Add animation and text switches (bottom row)
        controlsContainerView.addSubview(animationLabel)
        controlsContainerView.addSubview(animationSwitch)
        controlsContainerView.addSubview(textLabel)
        controlsContainerView.addSubview(textSwitch)
        controlsContainerView.addSubview(textField)
        
        // Layout top row - variant dropdown
        NSLayoutConstraint.activate([
            variantLabel.topAnchor.constraint(equalTo: controlsContainerView.topAnchor, constant: 8),
            variantLabel.leadingAnchor.constraint(equalTo: controlsContainerView.leadingAnchor, constant: 4),
            
            variantDropdownButton.centerYAnchor.constraint(equalTo: variantLabel.centerYAnchor),
            variantDropdownButton.leadingAnchor.constraint(equalTo: variantLabel.trailingAnchor, constant: 8),
            variantDropdownButton.trailingAnchor.constraint(equalTo: controlsContainerView.trailingAnchor),
            variantDropdownButton.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        // Layout second row - color dropdown
        NSLayoutConstraint.activate([
            colorLabel.topAnchor.constraint(equalTo: variantLabel.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: controlsContainerView.leadingAnchor, constant: 4),
            
            colorDropdownButton.centerYAnchor.constraint(equalTo: colorLabel.centerYAnchor),
            colorDropdownButton.leadingAnchor.constraint(equalTo: colorLabel.trailingAnchor, constant: 8),
            colorDropdownButton.trailingAnchor.constraint(equalTo: controlsContainerView.trailingAnchor),
            colorDropdownButton.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        // Layout third row - size control
        NSLayoutConstraint.activate([
            sizeLabel.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 16),
            sizeLabel.leadingAnchor.constraint(equalTo: controlsContainerView.leadingAnchor, constant: 4),
            
            sizeControl.centerYAnchor.constraint(equalTo: sizeLabel.centerYAnchor),
            sizeControl.leadingAnchor.constraint(equalTo: sizeLabel.trailingAnchor, constant: 8),
            sizeControl.widthAnchor.constraint(equalToConstant: 120)
        ])
        
        // Layout bottom row - animation switch, text switch and text field
        NSLayoutConstraint.activate([
            animationLabel.topAnchor.constraint(equalTo: sizeLabel.bottomAnchor, constant: 16),
            animationLabel.leadingAnchor.constraint(equalTo: controlsContainerView.leadingAnchor, constant: 4),
            
            animationSwitch.centerYAnchor.constraint(equalTo: animationLabel.centerYAnchor),
            animationSwitch.leadingAnchor.constraint(equalTo: animationLabel.trailingAnchor, constant: 8),
            
            textLabel.centerYAnchor.constraint(equalTo: animationLabel.centerYAnchor),
            textLabel.leadingAnchor.constraint(equalTo: animationSwitch.trailingAnchor, constant: 16),
            
            textSwitch.centerYAnchor.constraint(equalTo: textLabel.centerYAnchor),
            textSwitch.leadingAnchor.constraint(equalTo: textLabel.trailingAnchor, constant: 8),
            
            textField.topAnchor.constraint(equalTo: animationLabel.bottomAnchor, constant: 8),
            textField.leadingAnchor.constraint(equalTo: controlsContainerView.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: controlsContainerView.trailingAnchor),
            textField.heightAnchor.constraint(equalToConstant: 36),
            textField.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor, constant: -8)
        ])
    }
    
    private func createLoadingIndicator(startAnimating: Bool) {
        guard !isUpdatingIndicator else { return }
        isUpdatingIndicator = true
        
        // Save animation state to restore after recreation
        let wasAnimating = loadingIndicatorView?.isAnimating ?? false
        
        // Clean up existing indicator
        if loadingIndicatorView != nil {
            loadingIndicatorView.stopAnimating()
            loadingIndicatorView.removeFromSuperview()
        }
        
        // Create a new loader instance
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
        
        // Force a layout update to ensure proper sizing
        loadingContainerView.layoutIfNeeded()
        
        // Start animation if needed
        if startAnimating && (wasAnimating || animationSwitch.isOn) {
            // Use the main thread for animation start, but with a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                guard let self = self else { return }
                self.loadingIndicatorView.startAnimating()
                self.isUpdatingIndicator = false
            }
        } else {
            isUpdatingIndicator = false
        }
    }
    
    private func setupActions() {
        sizeControl.addTarget(self, action: #selector(sizeChanged), for: .valueChanged)
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
    
    private func configureColorDropdown() {
        var menuActions = [UIAction]()
        
        for (index, option) in colorOptions.enumerated() {
            let action = UIAction(title: option) { [weak self] _ in
                guard let self = self else { return }
                self.selectedColorIndex = index
                self.colorDropdownButton.setTitle(option, for: .normal)
                self.colorChanged()
            }
            
            // Mark the currently selected color
            if index == selectedColorIndex {
                action.state = .on
            }
            
            menuActions.append(action)
        }
        
        colorDropdownButton.menu = UIMenu(title: "Select Color", children: menuActions)
        colorDropdownButton.showsMenuAsPrimaryAction = true
    }
    
    // MARK: - Helper Methods
    
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
        switch selectedColorIndex {
        case 0: return .systemBlue
        case 1: return .systemRed
        case 2: return .systemGreen
        case 3: return .systemPurple
        case 4: return .black
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
        createLoadingIndicator(startAnimating: true)
    }
    
    // MARK: - Action Methods
    
    @objc private func sizeChanged() {
        // Check if the indicator already exists
        guard loadingIndicatorView != nil else { return }
        
        let wasAnimating = loadingIndicatorView.isAnimating
        
        // Stop any existing animations
        if wasAnimating {
            loadingIndicatorView.stopAnimating()
        }
        
        // Update size
        loadingIndicatorView.size = getSelectedSize()
        
        // Restart animation if needed
        if wasAnimating {
            // Give a moment for size change to take effect
            DispatchQueue.main.async {
                self.loadingIndicatorView.startAnimating()
            }
        }
    }
    
    @objc private func textSwitchChanged() {
        // Check if the indicator already exists
        guard loadingIndicatorView != nil else { return }
        
        let showText = textSwitch.isOn
        textField.isEnabled = showText
        
        if showText {
            loadingIndicatorView.text = textField.text?.isEmpty == false ? textField.text : "Loading"
        } else {
            loadingIndicatorView.text = nil
        }
    }
    
    @objc private func textFieldChanged() {
        // Check if the indicator already exists
        guard loadingIndicatorView != nil, textSwitch.isOn else { return }
        
        loadingIndicatorView.text = textField.text?.isEmpty == false ? textField.text : "Loading"
    }
    
    @objc private func animationSwitchChanged() {
        // Check if the indicator already exists
        guard loadingIndicatorView != nil else { return }
        
        if animationSwitch.isOn {
            // Force layout update
            view.layoutIfNeeded()
            
            // Start animation with a slight delay
            DispatchQueue.main.async {
                self.loadingIndicatorView.startAnimating()
            }
        } else {
            loadingIndicatorView.stopAnimating()
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func colorChanged() {
        // Check if the indicator already exists
        guard loadingIndicatorView != nil else { return }
        
        let wasAnimating = loadingIndicatorView.isAnimating
        
        // Stop any existing animations
        if wasAnimating {
            loadingIndicatorView.stopAnimating()
        }
        
        // Update color
        loadingIndicatorView.primaryColor = getSelectedColor()
        
        // Restart animation if needed
        if wasAnimating {
            // Give a moment for color change to take effect
            DispatchQueue.main.async {
                self.loadingIndicatorView.startAnimating()
            }
        }
    }
} 