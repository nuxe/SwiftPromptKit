import UIKit

// MARK: - LoaderVariant Enum

/// Defines the available loader variants
public enum LoaderVariant {
    case circular
    case classic
    case pulse
    case pulseDot
    case dots
    case typing
    case wave
    case bars
    case terminal
    case textBlink
    case textShimmer
    case loadingDots
}

// MARK: - LoaderSize Enum

/// Defines the available loader size options
public enum LoaderSize {
    case small
    case medium
    case large
    
    /// Returns size dimension value based on the selected size option
    var dimension: CGFloat {
        switch self {
        case .small: return 16
        case .medium: return 24
        case .large: return 32
        }
    }
    
    /// Returns internal elements size factor based on the selected size option
    var elementScale: CGFloat {
        switch self {
        case .small: return 0.75
        case .medium: return 1.0
        case .large: return 1.25
        }
    }
}

// MARK: - LoadingIndicatorViewDelegate

/// Protocol for loading indicator events
public protocol LoadingIndicatorViewDelegate: AnyObject {
    func loadingIndicatorDidStartAnimating(_ loadingIndicator: LoadingIndicatorView)
    func loadingIndicatorDidStopAnimating(_ loadingIndicator: LoadingIndicatorView)
}

// MARK: - LoadingIndicatorView

/// A customizable loading indicator view that supports various animation styles and sizes
public final class LoadingIndicatorView: UIView {
    
    // MARK: - Properties
    
    /// The variant of loader animation
    public var variant: LoaderVariant = .circular {
        didSet {
            if oldValue != variant {
                setupLoaderVariant()
            }
        }
    }
    
    /// The size of the loader
    public var size: LoaderSize = .medium {
        didSet {
            if oldValue != size {
                updateSize()
            }
        }
    }
    
    /// The text displayed with the loader (for text variants)
    public var text: String? {
        didSet {
            textLabel.text = text
            textLabel.isHidden = text == nil
        }
    }
    
    /// Primary color used for the loader
    public var primaryColor: UIColor = .systemBlue {
        didSet {
            updateColors()
        }
    }
    
    /// Delegate to handle loading indicator events
    public weak var delegate: LoadingIndicatorViewDelegate?
    
    /// Indicates whether the loader is currently animating
    private(set) var isAnimating: Bool = false
    
    // MARK: - UI Elements
    
    /// Container view for the loader animation elements
    private let loaderContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// Text label for displaying text with the loader (for text variants)
    private let textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.isHidden = true
        return label
    }()
    
    // MARK: - Initialization
    
    public init(variant: LoaderVariant = .circular, size: LoaderSize = .medium, text: String? = nil) {
        self.variant = variant
        self.size = size
        self.text = text
        
        super.init(frame: .zero)
        
        setupViews()
        setupLoaderVariant()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupViews()
        setupLoaderVariant()
    }
    
    // MARK: - Setup Methods
    
    private func setupViews() {
        backgroundColor = .clear
        
        addSubview(loaderContainerView)
        addSubview(textLabel)
        
        textLabel.text = text
        textLabel.isHidden = text == nil
        
        NSLayoutConstraint.activate([
            loaderContainerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            loaderContainerView.topAnchor.constraint(equalTo: topAnchor),
            
            textLabel.topAnchor.constraint(equalTo: loaderContainerView.bottomAnchor, constant: 8),
            textLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        updateSize()
    }
    
    private func setupLoaderVariant() {
        // Remove any existing loader subviews
        loaderContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        // Stop any ongoing animations
        layer.removeAllAnimations()
        
        // Create new loader based on variant
        switch variant {
        case .circular:
            setupCircularLoader()
        case .classic:
            setupClassicLoader()
        case .pulse:
            setupPulseLoader()
        case .pulseDot:
            setupPulseDotLoader()
        case .dots:
            setupDotsLoader()
        case .typing:
            setupTypingLoader()
        case .wave:
            setupWaveLoader()
        case .bars:
            setupBarsLoader()
        case .terminal:
            setupTerminalLoader()
        case .textBlink:
            setupTextBlinkLoader()
        case .textShimmer:
            setupTextShimmerLoader()
        case .loadingDots:
            setupLoadingDotsLoader()
        }
        
        // If was animating before switching variants, restart animation
        if isAnimating {
            startAnimating()
        }
    }
    
    private func updateSize() {
        let dimension = size.dimension
        
        NSLayoutConstraint.activate([
            loaderContainerView.widthAnchor.constraint(equalToConstant: dimension),
            loaderContainerView.heightAnchor.constraint(equalToConstant: dimension)
        ])
        
        // Update text size
        switch size {
        case .small:
            textLabel.font = .systemFont(ofSize: 12, weight: .medium)
        case .medium:
            textLabel.font = .systemFont(ofSize: 14, weight: .medium) 
        case .large:
            textLabel.font = .systemFont(ofSize: 16, weight: .medium)
        }
        
        // Refresh the loader variant with new size
        setupLoaderVariant()
    }
    
    private func updateColors() {
        // Refresh the loader with updated colors
        setupLoaderVariant()
    }
    
    // MARK: - Animation Control
    
    /// Starts the loading animation
    public func startAnimating() {
        guard !isAnimating else { return }
        
        isAnimating = true
        delegate?.loadingIndicatorDidStartAnimating(self)
        
        // Each loader type handles its own animation
        // The animation is set up in each setup method
    }
    
    /// Stops the loading animation
    public func stopAnimating() {
        guard isAnimating else { return }
        
        isAnimating = false
        delegate?.loadingIndicatorDidStopAnimating(self)
        
        // Stop animations
        loaderContainerView.layer.removeAllAnimations()
        loaderContainerView.subviews.forEach { 
            $0.layer.removeAllAnimations()
        }
    }
    
    // MARK: - Loader Setup Methods
    
    private func setupCircularLoader() {
        let circleView = UIView()
        circleView.translatesAutoresizingMaskIntoConstraints = false
        loaderContainerView.addSubview(circleView)
        
        // Size the circle based on loader size
        let dimension = size.dimension * 0.8
        
        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: loaderContainerView.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: loaderContainerView.centerYAnchor),
            circleView.widthAnchor.constraint(equalToConstant: dimension),
            circleView.heightAnchor.constraint(equalToConstant: dimension)
        ])
        
        // Create circular shape layer
        let circleLayer = CAShapeLayer()
        let center = CGPoint(x: dimension / 2, y: dimension / 2)
        let radius = dimension / 2
        let path = UIBezierPath(arcCenter: center,
                               radius: radius,
                               startAngle: 0,
                               endAngle: 2 * .pi,
                               clockwise: true)
        
        circleLayer.path = path.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = primaryColor.cgColor
        circleLayer.lineWidth = 2.0 * size.elementScale
        circleLayer.strokeStart = 0
        circleLayer.strokeEnd = 0.8
        circleLayer.lineCap = .round
        
        // Add the shape layer to the view
        circleView.layer.addSublayer(circleLayer)
        
        // Create and configure the rotation animation
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = 2 * Double.pi
        rotationAnimation.duration = 1.0
        rotationAnimation.repeatCount = .infinity
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        // Add animation immediately if isAnimating is true
        if isAnimating {
            circleView.layer.add(rotationAnimation, forKey: "rotationAnimation")
        }
    }
    
    private func setupClassicLoader() {
        let containerSize = size.dimension
        let center = CGPoint(x: containerSize / 2, y: containerSize / 2)
        let radius = containerSize / 2 - 2
        
        // Create 12 lines placed radially
        for i in 0..<12 {
            let line = CAShapeLayer()
            
            // Calculate angle for current line (30 degrees * index)
            let angle = CGFloat(i) * (CGFloat.pi / 6)
            
            // Calculate line start and end points
            let lineLength = radius * 0.4
            let startRadius = radius - lineLength
            let startPoint = CGPoint(
                x: center.x + startRadius * cos(angle),
                y: center.y + startRadius * sin(angle)
            )
            let endPoint = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            
            // Create the line path
            let path = UIBezierPath()
            path.move(to: startPoint)
            path.addLine(to: endPoint)
            
            // Configure the line
            line.path = path.cgPath
            line.strokeColor = primaryColor.cgColor
            line.lineWidth = 2.0 * size.elementScale
            line.lineCap = .round
            
            // Add to container
            loaderContainerView.layer.addSublayer(line)
            
            // Add fade animation
            if isAnimating {
                let fadeAnimation = CABasicAnimation(keyPath: "opacity")
                fadeAnimation.fromValue = 0.2
                fadeAnimation.toValue = 1.0
                fadeAnimation.duration = 1.0
                fadeAnimation.repeatCount = .infinity
                fadeAnimation.autoreverses = true
                
                // Offset the animation start time based on position
                fadeAnimation.beginTime = CACurrentMediaTime() + (Double(i) * 0.1)
                
                line.opacity = 0.2
                line.add(fadeAnimation, forKey: "fadeAnimation")
            }
        }
        
        // Add rotation animation to the entire container
        if isAnimating {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotationAnimation.fromValue = 0
            rotationAnimation.toValue = 2 * Double.pi
            rotationAnimation.duration = 2.0
            rotationAnimation.repeatCount = .infinity
            rotationAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
            
            loaderContainerView.layer.add(rotationAnimation, forKey: "rotationAnimation")
        }
    }
    
    private func setupPulseLoader() {
        let containerSize = size.dimension
        let circleSize = containerSize * 0.8
        
        let circleView = UIView()
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.backgroundColor = .clear
        circleView.layer.cornerRadius = circleSize / 2
        circleView.layer.borderWidth = 2.0 * size.elementScale
        circleView.layer.borderColor = primaryColor.cgColor
        loaderContainerView.addSubview(circleView)
        
        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: loaderContainerView.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: loaderContainerView.centerYAnchor),
            circleView.widthAnchor.constraint(equalToConstant: circleSize),
            circleView.heightAnchor.constraint(equalToConstant: circleSize)
        ])
        
        // Add pulse animation
        if isAnimating {
            // Scale animation
            let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
            pulseAnimation.fromValue = 0.8
            pulseAnimation.toValue = 1.1
            pulseAnimation.duration = 1.0
            pulseAnimation.repeatCount = .infinity
            pulseAnimation.autoreverses = true
            pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            // Opacity animation
            let opacityAnimation = CABasicAnimation(keyPath: "opacity")
            opacityAnimation.fromValue = 1.0
            opacityAnimation.toValue = 0.7
            opacityAnimation.duration = 1.0
            opacityAnimation.repeatCount = .infinity
            opacityAnimation.autoreverses = true
            opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            // Animation group
            let animationGroup = CAAnimationGroup()
            animationGroup.animations = [pulseAnimation, opacityAnimation]
            animationGroup.duration = 1.0
            animationGroup.repeatCount = .infinity
            animationGroup.autoreverses = true
            
            circleView.layer.add(animationGroup, forKey: "pulseAnimation")
        }
    }
    
    private func setupPulseDotLoader() {
        let containerSize = size.dimension
        let dotSize = containerSize * 0.3
        
        let dotView = UIView()
        dotView.translatesAutoresizingMaskIntoConstraints = false
        dotView.backgroundColor = primaryColor
        dotView.layer.cornerRadius = dotSize / 2
        loaderContainerView.addSubview(dotView)
        
        NSLayoutConstraint.activate([
            dotView.centerXAnchor.constraint(equalTo: loaderContainerView.centerXAnchor),
            dotView.centerYAnchor.constraint(equalTo: loaderContainerView.centerYAnchor),
            dotView.widthAnchor.constraint(equalToConstant: dotSize),
            dotView.heightAnchor.constraint(equalToConstant: dotSize)
        ])
        
        // Add pulse animation
        if isAnimating {
            // Scale animation
            let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
            pulseAnimation.fromValue = 0.7
            pulseAnimation.toValue = 1.3
            pulseAnimation.duration = 0.8
            pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            // Opacity animation 
            let opacityAnimation = CABasicAnimation(keyPath: "opacity")
            opacityAnimation.fromValue = 1.0
            opacityAnimation.toValue = 0.7
            opacityAnimation.duration = 0.8
            opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            // Animation group
            let animationGroup = CAAnimationGroup()
            animationGroup.animations = [pulseAnimation, opacityAnimation]
            animationGroup.duration = 1.6
            animationGroup.autoreverses = true
            animationGroup.repeatCount = .infinity
            
            dotView.layer.add(animationGroup, forKey: "pulseAnimation")
        }
    }
    
    private func setupDotsLoader() {
        let containerSize = size.dimension
        let dotSize = containerSize * 0.2
        let spacing = dotSize * 0.8
        let totalWidth = (dotSize * 3) + (spacing * 2)
        let startX = (containerSize - totalWidth) / 2
        
        // Create three dots in a row
        for i in 0..<3 {
            let dotView = UIView()
            dotView.translatesAutoresizingMaskIntoConstraints = false
            dotView.backgroundColor = primaryColor
            dotView.layer.cornerRadius = dotSize / 2
            loaderContainerView.addSubview(dotView)
            
            // Position the dot
            let xPosition = startX + (CGFloat(i) * (dotSize + spacing))
            
            NSLayoutConstraint.activate([
                dotView.widthAnchor.constraint(equalToConstant: dotSize),
                dotView.heightAnchor.constraint(equalToConstant: dotSize),
                dotView.centerYAnchor.constraint(equalTo: loaderContainerView.centerYAnchor),
                dotView.leadingAnchor.constraint(equalTo: loaderContainerView.leadingAnchor, constant: xPosition)
            ])
            
            // Add fade animation
            if isAnimating {
                let fadeAnimation = CAKeyframeAnimation(keyPath: "opacity")
                fadeAnimation.values = [1.0, 0.4, 1.0]
                fadeAnimation.keyTimes = [0, 0.5, 1]
                fadeAnimation.duration = 1.5
                fadeAnimation.repeatCount = .infinity
                
                // Offset animation start time based on dot position
                fadeAnimation.beginTime = CACurrentMediaTime() + (Double(i) * 0.2)
                
                dotView.layer.add(fadeAnimation, forKey: "fadeAnimation")
            }
        }
    }
    
    private func setupTypingLoader() {
        let containerSize = size.dimension
        let dotSize = containerSize * 0.18
        let spacing = dotSize
        let totalWidth = (dotSize * 3) + (spacing * 2)
        let startX = (containerSize - totalWidth) / 2
        
        // Create three dots in a row
        for i in 0..<3 {
            let dotView = UIView()
            dotView.translatesAutoresizingMaskIntoConstraints = false
            dotView.backgroundColor = primaryColor
            dotView.layer.cornerRadius = dotSize / 2
            loaderContainerView.addSubview(dotView)
            
            // Position the dot
            let xPosition = startX + (CGFloat(i) * (dotSize + spacing))
            
            NSLayoutConstraint.activate([
                dotView.widthAnchor.constraint(equalToConstant: dotSize),
                dotView.heightAnchor.constraint(equalToConstant: dotSize),
                dotView.centerYAnchor.constraint(equalTo: loaderContainerView.centerYAnchor),
                dotView.leadingAnchor.constraint(equalTo: loaderContainerView.leadingAnchor, constant: xPosition)
            ])
            
            // Add sequential animations
            if isAnimating {
                // For typing effect, we'll use a sequence of scale animations
                let scaleUpAnimation = CABasicAnimation(keyPath: "transform.scale")
                scaleUpAnimation.fromValue = 0.8
                scaleUpAnimation.toValue = 1.2
                scaleUpAnimation.duration = 0.3
                scaleUpAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
                
                let scaleDownAnimation = CABasicAnimation(keyPath: "transform.scale")
                scaleDownAnimation.fromValue = 1.2
                scaleDownAnimation.toValue = 0.8
                scaleDownAnimation.duration = 0.3
                scaleDownAnimation.timingFunction = CAMediaTimingFunction(name: .easeIn)
                scaleDownAnimation.beginTime = 0.3 // Start right after scale up
                
                // Group them together
                let animationGroup = CAAnimationGroup()
                animationGroup.animations = [scaleUpAnimation, scaleDownAnimation]
                animationGroup.duration = 1.5
                animationGroup.repeatCount = .infinity
                
                // Offset animation by dot position for sequential appearance
                animationGroup.beginTime = CACurrentMediaTime() + (Double(i) * 0.2)
                
                dotView.layer.add(animationGroup, forKey: "typingAnimation")
            }
        }
    }
    
    private func setupWaveLoader() {
        let containerSize = size.dimension
        let barWidth = containerSize * 0.12
        let barMaxHeight = containerSize * 0.7
        let spacing = containerSize * 0.08
        let numBars = 5
        let totalWidth = (barWidth * CGFloat(numBars)) + (spacing * CGFloat(numBars - 1))
        let startX = (containerSize - totalWidth) / 2
        
        // Create animated bars
        for i in 0..<numBars {
            let barView = UIView()
            barView.translatesAutoresizingMaskIntoConstraints = false
            barView.backgroundColor = primaryColor
            barView.layer.cornerRadius = barWidth * 0.2
            loaderContainerView.addSubview(barView)
            
            // Position the bar
            let xPosition = startX + (CGFloat(i) * (barWidth + spacing))
            let randomHeight = barMaxHeight * 0.3
            
            NSLayoutConstraint.activate([
                barView.widthAnchor.constraint(equalToConstant: barWidth),
                barView.heightAnchor.constraint(equalToConstant: randomHeight),
                barView.bottomAnchor.constraint(equalTo: loaderContainerView.centerYAnchor, constant: barMaxHeight/2),
                barView.leadingAnchor.constraint(equalTo: loaderContainerView.leadingAnchor, constant: xPosition)
            ])
            
            // Add wave animation
            if isAnimating {
                let initialHeight = barMaxHeight * 0.3
                
                // Create height changing animation
                let heightChange = CAKeyframeAnimation(keyPath: "bounds.size.height")
                heightChange.values = [
                    initialHeight,
                    barMaxHeight * 0.8,
                    barMaxHeight * 0.4,
                    barMaxHeight * 0.9,
                    initialHeight
                ]
                heightChange.keyTimes = [0, 0.25, 0.5, 0.75, 1.0]
                heightChange.duration = 1.5
                heightChange.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                heightChange.repeatCount = .infinity
                
                // Offset animation start for each bar
                heightChange.beginTime = CACurrentMediaTime() + (Double(i) * 0.2)
                
                barView.layer.add(heightChange, forKey: "waveAnimation")
            }
        }
    }
    
    private func setupBarsLoader() {
        let containerSize = size.dimension
        let barWidth = containerSize * 0.15
        let barHeight = containerSize * 0.7
        let spacing = containerSize * 0.1
        let numBars = 3
        let totalWidth = (barWidth * CGFloat(numBars)) + (spacing * CGFloat(numBars - 1))
        let startX = (containerSize - totalWidth) / 2
        
        // Create bars
        for i in 0..<numBars {
            let barView = UIView()
            barView.translatesAutoresizingMaskIntoConstraints = false
            barView.backgroundColor = primaryColor
            barView.layer.cornerRadius = 1.0
            loaderContainerView.addSubview(barView)
            
            // Position the bar
            let xPosition = startX + (CGFloat(i) * (barWidth + spacing))
            
            NSLayoutConstraint.activate([
                barView.widthAnchor.constraint(equalToConstant: barWidth),
                barView.heightAnchor.constraint(equalToConstant: barHeight),
                barView.centerYAnchor.constraint(equalTo: loaderContainerView.centerYAnchor),
                barView.leadingAnchor.constraint(equalTo: loaderContainerView.leadingAnchor, constant: xPosition)
            ])
            
            // Add animation
            if isAnimating {
                let scaleDownAnimation = CABasicAnimation(keyPath: "transform.scale.y")
                scaleDownAnimation.fromValue = 1.0
                scaleDownAnimation.toValue = 0.4
                scaleDownAnimation.duration = 0.5
                scaleDownAnimation.autoreverses = true
                scaleDownAnimation.repeatCount = .infinity
                scaleDownAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                
                // Offset animation start for each bar
                scaleDownAnimation.beginTime = CACurrentMediaTime() + (Double(i) * 0.2)
                
                barView.layer.add(scaleDownAnimation, forKey: "barAnimation")
            }
        }
    }
    
    private func setupTerminalLoader() {
        let containerSize = size.dimension
        let cursorSize = CGSize(width: containerSize * 0.15, height: containerSize * 0.6)
        
        // Create terminal cursor
        let cursorView = UIView()
        cursorView.translatesAutoresizingMaskIntoConstraints = false
        cursorView.backgroundColor = primaryColor
        loaderContainerView.addSubview(cursorView)
        
        NSLayoutConstraint.activate([
            cursorView.centerYAnchor.constraint(equalTo: loaderContainerView.centerYAnchor),
            cursorView.centerXAnchor.constraint(equalTo: loaderContainerView.centerXAnchor),
            cursorView.widthAnchor.constraint(equalToConstant: cursorSize.width),
            cursorView.heightAnchor.constraint(equalToConstant: cursorSize.height)
        ])
        
        // Add blinking animation
        if isAnimating {
            let blinkAnimation = CABasicAnimation(keyPath: "opacity")
            blinkAnimation.fromValue = 1.0
            blinkAnimation.toValue = 0.2
            blinkAnimation.duration = 0.8
            blinkAnimation.repeatCount = .infinity
            blinkAnimation.autoreverses = true
            
            cursorView.layer.add(blinkAnimation, forKey: "blinkAnimation")
        }
    }
    
    private func setupTextBlinkLoader() {
        // Configure the text label to be visible
        textLabel.isHidden = false
        textLabel.text = text ?? "Thinking"
        
        // Create blinking animation
        if isAnimating {
            let blinkAnimation = CABasicAnimation(keyPath: "opacity")
            blinkAnimation.fromValue = 1.0
            blinkAnimation.toValue = 0.4
            blinkAnimation.duration = 0.8
            blinkAnimation.repeatCount = .infinity
            blinkAnimation.autoreverses = true
            blinkAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            textLabel.layer.add(blinkAnimation, forKey: "blinkAnimation")
        }
    }
    
    private func setupTextShimmerLoader() {
        // Configure the text label to be visible
        textLabel.isHidden = false
        textLabel.text = text ?? "Thinking"
        
        // Create shimmer effect
        if isAnimating {
            // Create gradient layer for shimmer effect
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = textLabel.bounds
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            
            // Colors for gradient
            let lightColor = primaryColor.withAlphaComponent(0.9).cgColor
            let darkColor = primaryColor.withAlphaComponent(0.4).cgColor
            
            // Setup gradient with light color in middle
            gradientLayer.colors = [darkColor, lightColor, darkColor]
            gradientLayer.locations = [0.0, 0.5, 1.0]
            
            // Add gradient as mask
            textLabel.layer.mask = gradientLayer
            
            // Create animation
            let animation = CABasicAnimation(keyPath: "locations")
            animation.fromValue = [-1.0, -0.5, 0.0]
            animation.toValue = [1.0, 1.5, 2.0]
            animation.duration = 1.5
            animation.repeatCount = .infinity
            
            gradientLayer.add(animation, forKey: "shimmerAnimation")
            
            // Make sure text color is visible
            textLabel.textColor = primaryColor
        }
    }
    
    private func setupLoadingDotsLoader() {
        // Configure the text label to be visible
        textLabel.isHidden = false
        let baseText = text ?? "Loading"
        
        // Create animation for dots
        if isAnimating {
            // Use a repeating timer to update the dots
            let animationTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { [weak self] timer in
                guard let self = self, self.isAnimating else {
                    timer.invalidate()
                    return
                }
                
                // Cycle through different dots states
                // Using the tag property to track the current state
                let currentState = self.textLabel.tag
                let nextState = (currentState + 1) % 4
                
                switch nextState {
                case 0:
                    self.textLabel.text = baseText
                case 1:
                    self.textLabel.text = baseText + "."
                case 2:
                    self.textLabel.text = baseText + ".."
                case 3:
                    self.textLabel.text = baseText + "..."
                default:
                    self.textLabel.text = baseText
                }
                
                self.textLabel.tag = nextState
            }
            
            // Fire timer immediately for first update
            animationTimer.fire()
            
            // Store the timer in the view's layer using associated objects
            objc_setAssociatedObject(self, "loadingDotsTimer", animationTimer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        } else {
            // Remove the timer when not animating
            if let timer = objc_getAssociatedObject(self, "loadingDotsTimer") as? Timer {
                timer.invalidate()
                objc_setAssociatedObject(self, "loadingDotsTimer", nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            textLabel.text = baseText
        }
    }
    
    // Need to override removeFromSuperview to clean up timers
    public override func removeFromSuperview() {
        // Clean up any timers
        if let timer = objc_getAssociatedObject(self, "loadingDotsTimer") as? Timer {
            timer.invalidate()
        }
        super.removeFromSuperview()
    }
} 
