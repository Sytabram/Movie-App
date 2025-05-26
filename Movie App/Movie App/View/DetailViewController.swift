//
//  DetailViewController.swift
//  Movie App
//
//  Created by Bryan Zweiacker on 05.04.2024.
//

import UIKit
import SafariServices

class DetailViewController: UIViewController {
    
    var detailShowModel: ItemShowModel?
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var infoTableView: UITableView!
    
    var showsIDString: String = ""
    
    enum InfoSection: Int, CaseIterable {
        case summary = 0
        case details
        case schedule
        
        var title: String {
            switch self {
            case .summary: return "SUMMARY"
            case .details: return "INFORMATION"
            case .schedule: return "SCHEDULE"
            }
        }
    }
    
    struct DetailInfo {
        let key: String
        let value: String
    }
    
    var detailsArray: [DetailInfo] = []
    
    private var processedSummary: String?
    private var isProcessingSummary = false
    
    private struct TruncatedText {
        let text: String
        let isTruncated: Bool
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
        prepareDetailsArray()
        setupTableView()
        
        preprocessSummaryBeforeDisplay()
        
        if #available(iOS 15.0, *) {
            infoTableView.sectionHeaderTopPadding = 0
        }
    }
    
    private func preprocessSummaryBeforeDisplay() {
        guard let summary = detailShowModel?.summary, !summary.isEmpty else {
            return
        }
        
        isProcessingSummary = true
        
        let truncated = truncateText(summary, maxLength: 150)
        processedSummary = truncated.text
        
        DataController.sharedInstance.removeWords(from: summary) { [weak self] modifiedSummary in
            DispatchQueue.main.async {
                self?.processedSummary = modifiedSummary
                self?.isProcessingSummary = false
                
                if let summarySection = self?.getSectionIndex(for: .summary) {
                    self?.infoTableView.reloadSections(IndexSet(integer: summarySection), with: .none)
                }
            }
        }
    }
    
    private func truncateText(_ text: String, maxLength: Int) -> TruncatedText {
        if text.count <= maxLength {
            return TruncatedText(text: text, isTruncated: false)
        }
        
        let truncated = String(text.prefix(maxLength)) + "..."
        return TruncatedText(text: truncated, isTruncated: true)
    }
    
    private func getSectionIndex(for sectionType: InfoSection) -> Int? {
        var currentIndex = 0
        
        if let summary = detailShowModel?.summary, !summary.isEmpty {
            if sectionType == .summary {
                return currentIndex
            }
            currentIndex += 1
        }
        
        if !detailsArray.isEmpty {
            if sectionType == .details {
                return currentIndex
            }
            currentIndex += 1
        }
        
        if let scheduleDays = detailShowModel?.scheduleDays, !scheduleDays.isEmpty {
            if sectionType == .schedule {
                return currentIndex
            }
        }
        
        return nil
    }
    
    private func setupUI() {
        posterImageView.layer.cornerRadius = 20
        posterImageView.clipsToBounds = true
        
        nameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        ratingLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        ratingImageView.tintColor = UIColor.systemYellow
    }
    
    private func loadData() {
        showsIDString = detailShowModel!.id.codingKey.stringValue
        
        // Set the button icon to a checkmark if watchlisted
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
        
        // Set the z-position to ensure visibility over the background
        self.posterImageView.layer.zPosition = 1
        self.nameLabel.layer.zPosition = 1
    }
    
    private func prepareDetailsArray() {
        detailsArray = []
        
        // RELEASE DATE
        if let premiered = detailShowModel?.premiered, !premiered.isEmpty {
            detailsArray.append(DetailInfo(key: "RELEASE DATE", value: formatDate(premiered)))
        }
        
        // GENRES
        if let genres = detailShowModel?.genres, !genres.isEmpty {
            detailsArray.append(DetailInfo(key: "GENRES", value: genres.joined(separator: ", ")))
        }
        
        // NETWORK
        if let networkName = detailShowModel?.network, !networkName.isEmpty {
            detailsArray.append(DetailInfo(key: "NETWORK", value: networkName))
        }
        
        // STATUS
        if let status = detailShowModel?.status, !status.isEmpty {
            detailsArray.append(DetailInfo(key: "STATUS", value: status))
        }

        // RUNTIME
        if let runtime = detailShowModel?.runtime, runtime > 0 {
            detailsArray.append(DetailInfo(key: "RUNTIME", value: "\(runtime) minutes"))
        }
        
        // ENDED
        if let ended = detailShowModel?.ended, !ended.isEmpty {
            detailsArray.append(DetailInfo(key: "ENDED", value: formatDate(ended)))
        }
        
        // OFFICIAL SITE
        if let officialSite = detailShowModel?.officialSite, !officialSite.isEmpty {
            detailsArray.append(DetailInfo(key: "OFFICIAL SITE", value: officialSite))
        }
        
        // IMDB
        if let imdb = detailShowModel?.imdb, !imdb.isEmpty {
            detailsArray.append(DetailInfo(key: "IMDB", value: imdb))
        }
    }
    
    private func setupTableView() {
        infoTableView.delegate = self
        infoTableView.dataSource = self
        infoTableView.register(UITableViewCell.self, forCellReuseIdentifier: "DetailCell")
        infoTableView.register(SectionDetailHeaderView.self, forHeaderFooterViewReuseIdentifier: "HeaderView")
        
        infoTableView.backgroundColor = .darkGrayBackground
        infoTableView.separatorStyle = .singleLine
        infoTableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        infoTableView.separatorColor = UIColor.black
        infoTableView.showsVerticalScrollIndicator = false
        
        infoTableView.contentInset = .zero
        infoTableView.contentInsetAdjustmentBehavior = .never
        infoTableView.sectionHeaderTopPadding = 0 // iOS 15+
        
        infoTableView.clipsToBounds = true
        infoTableView.layer.cornerRadius = 10
        infoTableView.layer.borderWidth = 1
        infoTableView.layer.borderColor = UIColor.black.cgColor
    }
    
    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "d MMM yyyy"
            return outputFormatter.string(from: date)
        }
        return dateString
    }
    
    // MARK: - Add To Watchlist
    @IBAction func addToWatchlist(_ sender: UILongPressGestureRecognizer) {
        DataController.sharedInstance.updateWatchlist(showID: showsIDString)
        if DataController.sharedInstance.watchlistedShows.showsID.contains((showsIDString)) {
            addButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: UIControl.State.normal)
            showAnimatedCheckmarkToast()
        } else {
            addButton.setImage(UIImage(systemName: "plus.app"), for: UIControl.State.normal)
        }
    }
}

// MARK: - TableView Delegate & DataSource
extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        var count = 0
        
        if let summary = detailShowModel?.summary, !summary.isEmpty {
            count += 1
        }
        
        if !detailsArray.isEmpty {
            count += 1
        }
        
        if let scheduleDays = detailShowModel?.scheduleDays, !scheduleDays.isEmpty {
            count += 1
        }
        
        return count
    }
    
    private func getSectionType(for index: Int) -> InfoSection? {
        var currentIndex = 0
        
        if let summary = detailShowModel?.summary, !summary.isEmpty {
            if currentIndex == index {
                return .summary
            }
            currentIndex += 1
        }
        
        if !detailsArray.isEmpty {
            if currentIndex == index {
                return .details
            }
            currentIndex += 1
        }
        
        if let scheduleDays = detailShowModel?.scheduleDays, !scheduleDays.isEmpty {
            if currentIndex == index {
                return .schedule
            }
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let infoSection = InfoSection(rawValue: section) else { return 0 }
        
        switch infoSection {
        case .summary:
            return 1
        case .details:
            return detailsArray.count
        case .schedule:
            return detailShowModel?.scheduleDays.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let infoSection = getSectionType(for: indexPath.section) else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
            cell.accessoryView = nil
            cell.accessoryType = .none
            return cell
        }
        
        switch infoSection {
        case .summary:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
            cell.backgroundColor = .cellBackground
            
            cell.accessoryView = nil
            cell.accessoryType = .none
            
            var content = cell.defaultContentConfiguration()
            
            if let processedSummary = processedSummary {
                let truncated = truncateText(processedSummary, maxLength: 150)
                content.text = truncated.text
                
                if truncated.isTruncated {
                    let readMoreButton = createReadMoreButton(fullText: processedSummary)
                    cell.accessoryView = readMoreButton
                }
                
                content.textProperties.font = UIFont.systemFont(ofSize: 16)
                content.textProperties.color = .white
                content.textProperties.numberOfLines = 0
            } else {
                let truncated = truncateText(detailShowModel?.summary ?? "", maxLength: 150)
                content.text = truncated.text
                content.textProperties.font = UIFont.systemFont(ofSize: 16)
                content.textProperties.color = .white
                content.textProperties.numberOfLines = 0
            }
            
            cell.contentConfiguration = content
            cell.selectionStyle = .none
            return cell
            
            
        case .details:
            if indexPath.row < detailsArray.count {
                let detailInfo = detailsArray[indexPath.row]
                
                if detailInfo.key == "OFFICIAL SITE" {
                    let cell = createLinkCell(with: detailInfo.value, title: detailInfo.key, at: indexPath)
                    cell.accessoryView = nil
                    return cell
                }
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
                cell.backgroundColor = .cellBackground
                
                cell.accessoryView = nil
                cell.accessoryType = .none
                
                var content = cell.defaultContentConfiguration()
                
                content.text = detailInfo.key
                content.textProperties.font = UIFont.systemFont(ofSize: 12, weight: .medium)
                content.textProperties.color = .lightGrayText
                
                content.secondaryText = detailInfo.value
                content.secondaryTextProperties.font = UIFont.systemFont(ofSize: 16)
                content.secondaryTextProperties.color = .white
                content.textToSecondaryTextVerticalPadding = 4
                
                cell.contentConfiguration = content
                cell.selectionStyle = .none
                return cell
            }
            
        case .schedule:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
            cell.backgroundColor = .cellBackground
            
            cell.accessoryView = nil
            cell.accessoryType = .none
            
            var content = cell.defaultContentConfiguration()
            
            if let days = detailShowModel?.scheduleDays, indexPath.row < days.count {
                content.text = "SCHEDULE"
                content.textProperties.font = UIFont.systemFont(ofSize: 12, weight: .medium)
                content.textProperties.color = .lightGrayText
                
                var scheduleText = days[indexPath.row]
                if let time = detailShowModel?.scheduleTime, !time.isEmpty {
                    scheduleText += " at \(time)"
                }
                
                content.secondaryText = scheduleText
                content.secondaryTextProperties.font = UIFont.systemFont(ofSize: 16)
                content.secondaryTextProperties.color = .white
                content.textToSecondaryTextVerticalPadding = 4
            }
            
            cell.contentConfiguration = content
            cell.selectionStyle = .none
            return cell
        }
        
        let fallbackCell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        fallbackCell.accessoryView = nil
        fallbackCell.accessoryType = .none
        return fallbackCell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let infoSection = getSectionType(for: indexPath.section) else { return }
        
        if infoSection == .details && indexPath.row < detailsArray.count {
            let detailInfo = detailsArray[indexPath.row]
            
            if detailInfo.key == "OFFICIAL SITE" {
                openURL(detailInfo.value)
            }
        }
    }
    
    private func openURL(_ urlString: String) {
        var finalURLString = urlString
        
        if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
            finalURLString = "https://" + urlString
        }
        
        guard let url = URL(string: finalURLString) else {
            return
        }
        
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor = .systemBlue
        present(safariVC, animated: true)
    }

    private func createReadMoreButton(fullText: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Read more", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.sizeToFit()
        
        button.addTarget(self, action: #selector(showFullSummaryPopup(_:)), for: .touchUpInside)
        
        button.accessibilityHint = fullText
        
        return button
    }
    
    @objc private func showFullSummaryPopup(_ sender: UIButton) {
        guard let fullText = sender.accessibilityHint else { return }
        showSimpleSummaryViewController(with: fullText)
    }
    
    private func showSimpleSummaryViewController(with text: String) {
        
        let summaryViewController = UIViewController()
        summaryViewController.view.backgroundColor = UIColor.systemBackground
        
        let navController = UINavigationController(rootViewController: summaryViewController)
        
        summaryViewController.title = "Full Summary"
        summaryViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissSummaryViewController)
        )
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.font = UIFont.systemFont(ofSize: 16)
        textLabel.textColor = .label
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .byWordWrapping
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        summaryViewController.view.addSubview(scrollView)
        scrollView.addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            
            scrollView.topAnchor.constraint(equalTo: summaryViewController.view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: summaryViewController.view.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: summaryViewController.view.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: summaryViewController.view.safeAreaLayoutGuide.bottomAnchor),
            
            textLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            textLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            textLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            textLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        navController.modalPresentationStyle = .pageSheet
        
        present(navController, animated: true)
    }
    
    @objc private func dismissSummaryViewController() {
        dismiss(animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderView") as? SectionDetailHeaderView,
              let infoSection = getSectionType(for: section) else { return nil }
        
        headerView.configure(with: infoSection.title)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let infoSection = getSectionType(for: indexPath.section) else { return 44 }
        
        switch infoSection {
        case .summary:
            return UITableView.automaticDimension
        case .details:
            return 60
        case .schedule:
            return 60
        }
    }
    
}

// MARK: - Extension Animated Checkmark
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
    
    //MARK: - Generate Haptic Feedback
    private func generateHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}

//MARK: - View checkmark animation
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
    
    // MARK: - Setup
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
    
    // MARK: - Override Layout Subviews
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update the path when the size changes
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.width * 0.25, y: bounds.height * 0.5))
        path.addLine(to: CGPoint(x: bounds.width * 0.45, y: bounds.height * 0.7))
        path.addLine(to: CGPoint(x: bounds.width * 0.75, y: bounds.height * 0.3))
        checkmarkLayer.path = path.cgPath
    }
    
    // MARK: - Animate
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

// MARK: - Checkmark Animation Delegate
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

extension UIColor {
    static let darkGrayBackground = UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1.0)
    static let lightGrayText = UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1.0)
    static let cellBackground = UIColor(red: 46/255, green: 46/255, blue: 46/255, alpha: 1.0)
}



extension DetailViewController {
    
    private func createLinkCell(with url: String, title: String, at indexPath: IndexPath) -> UITableViewCell {
        let cell = infoTableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        cell.backgroundColor = .cellBackground
        
        cell.accessoryView = nil
        cell.accessoryType = .none
        
        var content = cell.defaultContentConfiguration()
        
        content.text = title
        content.textProperties.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        content.textProperties.color = .lightGrayText
        
        content.secondaryText = url
        content.secondaryTextProperties.font = UIFont.systemFont(ofSize: 16)
        content.secondaryTextProperties.color = .systemBlue
        content.textToSecondaryTextVerticalPadding = 4
        
        cell.contentConfiguration = content
        cell.selectionStyle = .default
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
}
