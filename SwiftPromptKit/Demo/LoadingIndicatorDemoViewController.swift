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
    
    // Replace segmented control with picker view to handle long variant names
    private let variantPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        return pickerView
    }()
    
    private let variantOptions: [String] = [
        "circular", "classic", "pulse", "pulse-dot", 
        "dots", "typing", "wave", "bars", 
        "terminal", "text-blink", "text-shimmer", "loading-dots"
    ]
    
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
    
    private let loadingIndicatorView: LoadingIndicatorView = {
        let view = LoadingIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
        loadingIndicatorView.startAnimating()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "Loading Indicator Demo"
        
        setupScrollView()
        setupControls()
        setupLoadingIndicator()
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
        // Variant selector - use picker instead of segmented control
        let variantLabel = createLabel(text: "Loader Variant:")
        
        variantPickerView.delegate = self
        variantPickerView.dataSource = self
        let variantPickerWrapper = createControlWrapper(for: variantPickerView, height: 120)
        
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
        contentStackView.addArrangedSubview(variantPickerWrapper)
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
    }
    
    private func setupLoadingIndicator() {
        // Create a container for the loading indicator
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 16
        
        containerView.addSubview(loadingIndicatorView)
        
        NSLayoutConstraint.activate([
            loadingIndicatorView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            loadingIndicatorView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 200),
        ])
        
        contentStackView.addArrangedSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalTo: contentStackView.widthAnchor)
        ])
    }
    
    private func setupActions() {
        // Now using picker view instead of segmented control for variants
        sizeControl.addTarget(self, action: #selector(sizeChanged), for: .valueChanged)
        colorControl.addTarget(self, action: #selector(colorChanged), for: .valueChanged)
        textSwitch.addTarget(self, action: #selector(textSwitchChanged), for: .valueChanged)
        animationSwitch.addTarget(self, action: #selector(animationSwitchChanged), for: .valueChanged)
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        // Add tap gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
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
    
    // MARK: - Action Methods
    
    private func updateVariant(at index: Int) {
        let variant: LoaderVariant
        
        switch index {
        case 0:
            variant = .circular
        case 1:
            variant = .classic
        case 2:
            variant = .pulse
        case 3:
            variant = .pulseDot
        case 4:
            variant = .dots
        case 5:
            variant = .typing
        case 6:
            variant = .wave
        case 7:
            variant = .bars
        case 8:
            variant = .terminal
        case 9:
            variant = .textBlink
        case 10:
            variant = .textShimmer
        case 11:
            variant = .loadingDots
        default:
            variant = .circular
        }
        
        // First stop any current animation
        loadingIndicatorView.stopAnimating()
        
        // Update the variant
        loadingIndicatorView.variant = variant
        
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
        
        // Restart animation if it was on
        if animationSwitch.isOn {
            loadingIndicatorView.startAnimating()
        }
    }
    
    @objc private func sizeChanged() {
        let size: LoaderSize
        
        switch sizeControl.selectedSegmentIndex {
        case 0:
            size = .small
        case 1:
            size = .medium
        case 2:
            size = .large
        default:
            size = .medium
        }
        
        loadingIndicatorView.size = size
    }
    
    @objc private func colorChanged() {
        let color: UIColor
        
        switch colorControl.selectedSegmentIndex {
        case 0:
            color = .systemBlue
        case 1:
            color = .systemRed
        case 2:
            color = .systemGreen
        case 3:
            color = .systemPurple
        default:
            color = .systemBlue
        }
        
        loadingIndicatorView.primaryColor = color
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

// MARK: - UIPickerViewDelegate & UIPickerViewDataSource

extension LoadingIndicatorDemoViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return variantOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return variantOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateVariant(at: row)
    }
} 