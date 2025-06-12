//
//  SectionHeaderView.swift
//  ShowApp
//
//  Created by Bryan Zweiacker on 10.12.2024.
//

import UIKit

class SectionHeaderView: UICollectionReusableView {
    
    // MARK: - Constants
    
    static let reuseIdentifier = "SectionHeaderView"
    
    private enum Constants {
        static let topPadding: CGFloat = 8
        static let fontSize: CGFloat = 24
    }
    
    // MARK: - UI Components
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: Constants.fontSize, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        addSubview(stackView)
        stackView.addArrangedSubview(label)
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.topPadding),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Public Methods
    
    func setTitle(_ title: String) {
        label.text = title
    }
}
