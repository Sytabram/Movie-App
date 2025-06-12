//
//  ResultTableViewCell.swift
//  Movie App
//
//  Created by Bryan Zweiacker on 06.04.2024.
//

import UIKit

class ResultTableViewCell: UITableViewCell {
    
    // MARK: - Constants
    
    static let reuseIdentifier = "ResultTableViewCell"
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.text = nil
        detailTextLabel?.text = nil
        imageView?.image = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        selectionStyle = .default
    }
}
