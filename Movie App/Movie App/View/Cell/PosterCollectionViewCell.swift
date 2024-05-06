//
//  PosterCollectionViewCell.swift
//  Movie App
//
//  Created by Bryan Zweiacker on 26.03.2024.
//

import UIKit

class PosterCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var posterNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.posterImageView.layer.masksToBounds = true
        self.posterImageView.layer.cornerRadius = 25
        self.backgroundColor = .clear

    }


}
