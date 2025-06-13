//
//  SectionDetailHeaderView.swift
//  ShowApp
//
//  Created by Bryan Zweiacker on 22.05.2025.
//

import UIKit

class SectionDetailHeaderView: UITableViewHeaderFooterView {
    
    // MARK: - Constants
    
    static let reuseIdentifier = "SectionDetailHeaderView"
    
    private enum Constants {
        static let horizontalPadding: CGFloat = 15
        static let topPadding: CGFloat = 5
        static let bottomPadding: CGFloat = 8
        static let fontSize: CGFloat = 14
    }
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: Constants.fontSize, weight: .medium)
        label.textColor = .lightGrayText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializers
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        contentView.backgroundColor = .darkGrayBackground
        contentView.addSubview(titleLabel)
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.horizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.horizontalPadding),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.topPadding),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.bottomPadding)
        ])
    }
    
    // MARK: - Public Methods
    
    func configure(with title: String) {
        titleLabel.text = title
    }
}
