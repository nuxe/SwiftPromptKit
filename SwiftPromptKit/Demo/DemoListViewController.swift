import UIKit

/// A view controller displaying a list of all available components in SwiftPromptKit
final class DemoListViewController: UIViewController {
    
    // MARK: - Types
    
    /// Represents a component in the SwiftPromptKit library
    struct ComponentItem {
        let name: String
        let description: String
        let status: ComponentStatus
        let demoViewControllerProvider: () -> UIViewController
        
        enum ComponentStatus {
            case implemented
            case inProgress
            case notImplemented
        }
    }
    
    // MARK: - Properties
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    private let components: [ComponentItem] = [
        ComponentItem(
            name: "PromptInputView",
            description: "A user-friendly input component for text entry",
            status: .implemented,
            demoViewControllerProvider: { PromptInputDemoViewController() }
        ),
        ComponentItem(
            name: "MessageBubbleView",
            description: "Chat bubbles for messages with different styles",
            status: .notImplemented,
            demoViewControllerProvider: { NotImplementedComponentViewController(componentName: "MessageBubbleView") }
        ),
        ComponentItem(
            name: "MarkdownRenderer",
            description: "Renders Markdown-formatted text with rich formatting",
            status: .notImplemented,
            demoViewControllerProvider: { NotImplementedComponentViewController(componentName: "MarkdownRenderer") }
        ),
        ComponentItem(
            name: "AutoScrollingChatView",
            description: "Scrollable chat container that automatically scrolls to latest messages",
            status: .notImplemented,
            demoViewControllerProvider: { NotImplementedComponentViewController(componentName: "AutoScrollingChatView") }
        ),
        ComponentItem(
            name: "LoadingIndicatorView",
            description: "Visually appealing loader to indicate processing",
            status: .notImplemented,
            demoViewControllerProvider: { NotImplementedComponentViewController(componentName: "LoadingIndicatorView") }
        ),
        ComponentItem(
            name: "PromptSuggestionView",
            description: "Interactive prompts or suggestion chips",
            status: .notImplemented,
            demoViewControllerProvider: { NotImplementedComponentViewController(componentName: "PromptSuggestionView") }
        ),
        ComponentItem(
            name: "RealTimeResponseHandler",
            description: "Logic to handle streaming responses from AI models",
            status: .notImplemented,
            demoViewControllerProvider: { NotImplementedComponentViewController(componentName: "RealTimeResponseHandler") }
        ),
        ComponentItem(
            name: "ReasoningDisclosureView",
            description: "Expandable view to display AI reasoning steps",
            status: .notImplemented,
            demoViewControllerProvider: { NotImplementedComponentViewController(componentName: "ReasoningDisclosureView") }
        )
    ]
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        title = "SwiftPromptKit Components"
        
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ComponentCell.self, forCellReuseIdentifier: ComponentCell.reuseIdentifier)
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource

extension DemoListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return components.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ComponentCell.reuseIdentifier, for: indexPath) as! ComponentCell
        let component = components[indexPath.row]
        cell.configure(with: component)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Available Components"
    }
}

// MARK: - UITableViewDelegate

extension DemoListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let component = components[indexPath.row]
        let viewController = component.demoViewControllerProvider()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - ComponentCell

final class ComponentCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "ComponentCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        return label
    }()
    
    private let statusView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4
        return view
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Public Methods
    
    func configure(with component: DemoListViewController.ComponentItem) {
        titleLabel.text = component.name
        descriptionLabel.text = component.description
        
        switch component.status {
        case .implemented:
            statusView.backgroundColor = .systemGreen
            accessoryType = .disclosureIndicator
            selectionStyle = .default
            isUserInteractionEnabled = true
        case .inProgress:
            statusView.backgroundColor = .systemYellow
            accessoryType = .disclosureIndicator
            selectionStyle = .default
            isUserInteractionEnabled = true
        case .notImplemented:
            statusView.backgroundColor = .systemGray
            accessoryType = .none
            selectionStyle = .none
            isUserInteractionEnabled = true // Still allowing selection to show the not implemented message
        }
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(statusView)
        
        NSLayoutConstraint.activate([
            statusView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statusView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statusView.widthAnchor.constraint(equalToConstant: 8),
            statusView.heightAnchor.constraint(equalToConstant: 8),
            
            titleLabel.leadingAnchor.constraint(equalTo: statusView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16)
        ])
    }
} 