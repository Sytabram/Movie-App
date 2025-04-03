//
//  DetailViewController.swift
//  Movie App
//
//  Created by Bryan Zweiacker on 05.04.2024.
//

import UIKit

class DetailViewController: UIViewController {
    
    var detailShowModel: ItemShowModel?
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    var showsIDString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showsIDString = detailShowModel!.id.codingKey.stringValue
        if DataController.sharedInstance.watchlistedShows.showsID.contains((showsIDString)) {
            addButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: UIControl.State.normal)
        } else {
            addButton.setImage(UIImage(systemName: "plus.app"), for: UIControl.State.normal)
        }
        // Set the rating image view to a filled star icon
        ratingImageView.image = UIImage(systemName: "star.fill")
        
        // Set the name label
        nameLabel.text = detailShowModel?.name
        self.nameLabel.numberOfLines = 2
        self.nameLabel.lineBreakMode = .byTruncatingTail
        
        // Remove specific words from the show's summary
        DataController.sharedInstance.removeWords(from: detailShowModel?.summary ?? "") { modifiedSummary in
            self.descriptionTextView.text = modifiedSummary
        }
        
        // Set the rating label text to the show's average rating if available
        if let averageRating = detailShowModel?.rating {
            ratingLabel.text = "\(averageRating)"
        } else {
            ratingLabel.isHidden = true
            ratingImageView.isHidden = true
        }
        Task {
            do {
                // Load the poster image from the URL
                let image = await APIController.sharedInstance.loadImage(from: detailShowModel?.imageUrl)
                DispatchQueue.main.async {
                    self.posterImageView.image = image
                }
                // Load the background image URL
                let backgroundURLString = try await DataController.sharedInstance.getBackgroundImage(idString: String(detailShowModel!.id))
                let imageBackground = await APIController.sharedInstance.loadImage(from: backgroundURLString)
                DispatchQueue.main.async {
                    self.backgroundImageView.image = imageBackground
                }
                
            } catch {
                // Handle failure to retrieve the background image URL by displaying a default image
                DispatchQueue.main.async {
                    self.backgroundImageView.image = APIController.sharedInstance.defaultImage
                    self.backgroundImageView.contentMode = .scaleToFill
                }
            }
        }
        self.backgroundImageView.contentMode = .scaleToFill
        
        // Set the z-position of the poster image view and name label to ensure they are above the background image view
        self.posterImageView.layer.zPosition = 1
        self.nameLabel.layer.zPosition = 1
    }
    
    @IBAction func addToWatchlist(_ sender: UILongPressGestureRecognizer) {
        DataController.sharedInstance.updateWatchlist(showID: showsIDString)
        if DataController.sharedInstance.watchlistedShows.showsID.contains((showsIDString)) {
            addButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: UIControl.State.normal)
        } else {
            addButton.setImage(UIImage(systemName: "plus.app"), for: UIControl.State.normal)
        }
        showAnimatedCheckmarkToast()
    }
}

extension DetailViewController {
    func showAnimatedCheckmarkToast(duration: TimeInterval = 1.5) {
        // Create the toast view
        let toastContainer = UIView()
        toastContainer.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastContainer.layer.cornerRadius = 30
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Create the view to draw the animated check mark
        let checkmarkView = CheckmarkView(frame: .zero)
        checkmarkView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the check mark view to the container
        toastContainer.addSubview(checkmarkView)
        
        // Add the toast view to the main view
        view.addSubview(toastContainer)
        
        // Configuring constraints
        NSLayoutConstraint.activate([
            // Container constraints
            toastContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            toastContainer.widthAnchor.constraint(equalToConstant: 120),
            toastContainer.heightAnchor.constraint(equalToConstant: 120),
            
            // Constraints for the check mark view
            checkmarkView.centerXAnchor.constraint(equalTo: toastContainer.centerXAnchor),
            checkmarkView.centerYAnchor.constraint(equalTo: toastContainer.centerYAnchor),
            checkmarkView.widthAnchor.constraint(equalToConstant: 70),
            checkmarkView.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        // Container appearance animation
        toastContainer.alpha = 0
        toastContainer.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.3, animations: {
            toastContainer.alpha = 1
            toastContainer.transform = CGAffineTransform.identity
        }) { _ in
            // Generate haptic feedback on full appearance
            self.generateHapticFeedback(style: .medium)
            
            // Start check animation
            checkmarkView.animate(completion: {
                // Generate a second haptic feedback when the check mark is complete
                self.generateHapticFeedback(style: .heavy)
            })
            
            // Fade-out animation after specified time
            UIView.animate(withDuration: 0.3, delay: duration, options: [], animations: {
                toastContainer.alpha = 0
                toastContainer.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { _ in
                toastContainer.removeFromSuperview()
            }
        }
    }
    
    // Method for generating haptic feedback
    private func generateHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}

// Custom view for check animation
class CheckmarkView: UIView {
    private let checkmarkLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        // Configuring the check mark layer
        checkmarkLayer.fillColor = nil
        checkmarkLayer.strokeColor = UIColor.white.cgColor
        checkmarkLayer.lineWidth = 5
        checkmarkLayer.lineCap = .round
        checkmarkLayer.lineJoin = .round
        
        // Create the check mark path
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.width * 0.25, y: bounds.height * 0.5))
        path.addLine(to: CGPoint(x: bounds.width * 0.45, y: bounds.height * 0.7))
        path.addLine(to: CGPoint(x: bounds.width * 0.75, y: bounds.height * 0.3))
        
        checkmarkLayer.path = path.cgPath
        checkmarkLayer.strokeEnd = 0 // Start with an invisible check mark
        
        layer.addSublayer(checkmarkLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update the path when the size changes
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.width * 0.25, y: bounds.height * 0.5))
        path.addLine(to: CGPoint(x: bounds.width * 0.45, y: bounds.height * 0.7))
        path.addLine(to: CGPoint(x: bounds.width * 0.75, y: bounds.height * 0.3))
        checkmarkLayer.path = path.cgPath
    }
    
    func animate(completion: (() -> Void)? = nil) {
        // Animation of the check layout
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 0.5
        animation.fromValue = 0
        animation.toValue = 1
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        
        // Add a delegate to detect the end of the animation
        let animationDelegate = CheckmarkAnimationDelegate(completion: {
            // Pulse animation after the trace
            let pulseAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
            pulseAnimation.values = [1.0, 1.2, 1.0]
            pulseAnimation.keyTimes = [0, 0.5, 1]
            pulseAnimation.duration = 0.3
            
            self.layer.add(pulseAnimation, forKey: "pulseAnimation")
            
            // Call the completion handler
            completion?()
        })
        
        animation.delegate = animationDelegate
        
        // Keep the reference to the delegate
        objc_setAssociatedObject(checkmarkLayer, UnsafeRawPointer(bitPattern: 1)!, animationDelegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        checkmarkLayer.strokeEnd = 1
        checkmarkLayer.add(animation, forKey: "checkmarkAnimation")
    }
}

// Delegate to detect the end of the animation
class CheckmarkAnimationDelegate: NSObject, CAAnimationDelegate {
    private let completion: () -> Void
    
    init(completion: @escaping () -> Void) {
        self.completion = completion
        super.init()
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            completion()
        }
    }
}
