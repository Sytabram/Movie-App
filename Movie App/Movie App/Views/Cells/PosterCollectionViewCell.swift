//
//  PosterCollectionViewCell.swift
//  Movie App
//
//  Created by Bryan Zweiacker on 26.03.2024.
//

import UIKit

class PosterCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Constants
    
    static let reuseIdentifier = "PosterCollectionViewCell"
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var posterNameLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        posterNameLabel.text = nil
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        posterImageView.layer.masksToBounds = true
        posterImageView.layer.cornerRadius = 25
        backgroundColor = .clear
    }
    
    // MARK: - Public Methods
    
    func configure(with show: ShowItem) {
        posterNameLabel.text = show.name
        loadPosterImage(from: show.imageUrl)
    }
    
    // MARK: - Private Methods
    
    private func loadPosterImage(from urlString: String?) {
        guard let imageURLString = urlString else {
            posterImageView.image = APIController.shared.defaultImage
            return
        }
        
        Task {
            let image = await APIController.shared.loadImage(from: imageURLString)
            await MainActor.run {
                self.posterImageView.image = image
            }
        }
    }
}
