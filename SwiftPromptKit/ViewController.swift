//
//  ViewController.swift
//  SwiftPromptKit
//
//  Created by Kush Agrawal on 3/17/25.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "SwiftPromptKit Components"
        label.font = .boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "UI components for AI-driven chat interfaces"
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let demoButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Show Demo Components", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
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
        title = "SwiftPromptKit"
        
        setupLabels()
        setupButton()
    }
    
    private func setupLabels() {
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupButton() {
        view.addSubview(demoButton)
        
        NSLayoutConstraint.activate([
            demoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            demoButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            demoButton.widthAnchor.constraint(equalToConstant: 250),
            demoButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        demoButton.addTarget(self, action: #selector(showDemoComponents), for: .touchUpInside)
    }
    
    @objc private func showDemoComponents() {
        // For now, let's present a message that this is a work in progress
        let alert = UIAlertController(
            title: "Coming Soon", 
            message: "Demo components are being developed. Please check back later.", 
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

