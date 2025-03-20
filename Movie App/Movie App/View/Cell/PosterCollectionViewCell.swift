//
//  PosterCollectionViewCell.swift
//  Movie App
//
//  Created by Bryan Zweiacker on 26.03.2024.
//

import UIKit

class PosterCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "PosterCollectionViewCell"

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var posterNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.posterImageView.layer.masksToBounds = true
        self.posterImageView.layer.cornerRadius = 25
        self.backgroundColor = .clear

    }

    func configureCell(_ show: ItemShowModel) {
        posterNameLabel.text = show.name
        if let imageURLString = show.imageUrl {
            Task {
                do {
                    let image = await APIController.sharedInstance.loadImage(from: imageURLString)
                    DispatchQueue.main.async {
                        // Update the cell image with the loaded image
                        self.posterImageView.image = image
                    }
                }
            }
        }
    }
}
