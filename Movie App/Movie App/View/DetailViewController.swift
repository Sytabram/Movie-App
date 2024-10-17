//
//  DetailViewController.swift
//  Movie App
//
//  Created by Bryan Zweiacker on 05.04.2024.
//

import UIKit

class DetailViewController: UIViewController {
    
    var detailShowModel: ShowModel?
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var ratingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the rating image view to a filled star icon
        ratingImageView.image = UIImage(systemName: "star.fill")
        
        // Set the name label
        nameLabel.text = detailShowModel?.name
        nameLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        // Remove specific words from the show's summary
        DataController.sharedInstance.removeWords(from: detailShowModel?.summary ?? "") { modifiedSummary in
            self.descriptionTextView.text = modifiedSummary
        }
        
        // Set the rating label text to the show's average rating if available, otherwise set it to "N/A"
        if let averageRating = detailShowModel?.rating?.average {
            ratingLabel.text = "\(averageRating)"
        } else {
            ratingLabel.text = "N/A"
        }
        
        // Load the poster image from the URL
        APIController.sharedInstance.loadImage(from: detailShowModel?.image?.original) { image in
            DispatchQueue.main.async {
                self.posterImageView.image = image
            }
        }
        
        // Load the background image URL
        DataController.sharedInstance.getBackgroundImage(idString: String(detailShowModel!.id)) { backgroundURLString in
            APIController.sharedInstance.loadImage(from: backgroundURLString) { image in
                DispatchQueue.main.async {
                    self.backgroundImageView.image = image
                }
            }
        } onFailure: {
            // Handle failure to retrieve the background image URL by displaying a default image
            DispatchQueue.main.async {
                self.backgroundImageView.image = APIController.sharedInstance.defaultImage
                self.backgroundImageView.contentMode = .scaleToFill
            }
        }
        self.backgroundImageView.contentMode = .scaleToFill
        
        // Set the z-position of the poster image view and name label to ensure they are above the background image view
        self.posterImageView.layer.zPosition = 1
        self.nameLabel.layer.zPosition = 1
    }

}
