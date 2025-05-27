//
//  DetailViewController.swift
//  Movie App
//
//  Created by Bryan Zweiacker on 05.04.2024.
//

import UIKit
import SafariServices

// MARK: - DetailViewController

class DetailViewController: UIViewController {
    
    // MARK: - Properties
    
    var detailShowModel: ItemShowModel?
    private var showsIDString: String = ""
    private var detailsArray: [DetailInfo] = []
    private var processedSummary: String?
    private var isProcessingSummary = false
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var infoTableView: UITableView!
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
        prepareDetailsArray()
        setupTableView()
        preprocessSummary()
        
        if #available(iOS 15.0, *) {
            infoTableView.sectionHeaderTopPadding = 0
        }
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        // Configure poster image view
        posterImageView.layer.cornerRadius = 25
        posterImageView.clipsToBounds = true
        posterImageView.layer.zPosition = 1
        
        // Configure labels
        nameLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        nameLabel.layer.zPosition = 1
        ratingLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        // Configure rating image
        ratingImageView.tintColor = UIColor.systemYellow
        ratingImageView.image = UIImage(systemName: "star.fill")
        
        // Configure background image
        backgroundImageView.contentMode = .scaleToFill
    }
    
    private func setupTableView() {
        infoTableView.delegate = self
        infoTableView.dataSource = self
        infoTableView.register(UITableViewCell.self, forCellReuseIdentifier: "DetailCell")
        infoTableView.register(SectionDetailHeaderView.self, forHeaderFooterViewReuseIdentifier: "HeaderView")
        
        // Configure appearance
        infoTableView.backgroundColor = .darkGrayBackground
        infoTableView.separatorStyle = .singleLine
        infoTableView.separatorInset = UIEdgeInsets.zero
        infoTableView.separatorColor = UIColor.black
        infoTableView.showsVerticalScrollIndicator = false
        
        // Configure layout
        infoTableView.contentInset = .zero
        infoTableView.contentInsetAdjustmentBehavior = .never
        infoTableView.sectionHeaderTopPadding = 0
        
        // Configure border
        infoTableView.clipsToBounds = true
        infoTableView.layer.cornerRadius = 10
        infoTableView.layer.borderWidth = 1
        infoTableView.layer.borderColor = UIColor.black.cgColor
    }
    
    // MARK: - Data Loading Methods
    
    private func loadData() {
        guard let detailShowModel = detailShowModel else { return }
        
        showsIDString = detailShowModel.id.codingKey.stringValue
        
        // Configure watchlist button
        updateWatchlistButton()
        
        // Configure name label
        nameLabel.text = detailShowModel.name
        nameLabel.numberOfLines = 2
        nameLabel.lineBreakMode = .byTruncatingTail
        
        // Configure rating
        setupRatingDisplay()
        
        // Load images asynchronously
        loadImages()
    }
    
    private func updateWatchlistButton() {
        let isWatchlisted = DataController.sharedInstance.watchlistedShows.showsID.contains(showsIDString)
        let imageName = isWatchlisted ? "checkmark.square.fill" : "plus.app"
        addButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    private func setupRatingDisplay() {
        if let averageRating = detailShowModel?.rating {
            ratingLabel.text = "\(averageRating)"
            ratingLabel.isHidden = false
            ratingImageView.isHidden = false
        } else {
            ratingLabel.isHidden = true
            ratingImageView.isHidden = true
        }
    }
    
    private func loadImages() {
        guard let detailShowModel = detailShowModel else { return }
        
        Task {
            do {
                // Load poster image
                let posterImage = await APIController.sharedInstance.loadImage(from: detailShowModel.imageUrl)
                
                // Load background image
                let backgroundURLString = try await DataController.sharedInstance.getBackgroundImage(idString: String(detailShowModel.id))
                let backgroundImage = await APIController.sharedInstance.loadImage(from: backgroundURLString)
                
                DispatchQueue.main.async {
                    self.posterImageView.image = posterImage
                    self.backgroundImageView.image = backgroundImage
                }
                
            } catch {
                // Handle failure with default image
                DispatchQueue.main.async {
                    self.posterImageView.image = APIController.sharedInstance.defaultImage
                    self.posterImageView.contentMode = .center
                }
            }
        }
    }
    
    private func prepareDetailsArray() {
        detailsArray = []
        guard let detailShowModel = detailShowModel else { return }
        
        // Release date
        if let premiered = detailShowModel.premiered, !premiered.isEmpty {
            detailsArray.append(DetailInfo(key: "RELEASE DATE", value: formatDate(premiered)))
        }
        
        // Genres
        if let genres = detailShowModel.genres, !genres.isEmpty {
            detailsArray.append(DetailInfo(key: "GENRES", value: genres.joined(separator: ", ")))
        }
        
        // Network
        if let networkName = detailShowModel.network, !networkName.isEmpty {
            detailsArray.append(DetailInfo(key: "NETWORK", value: networkName))
        }
        
        // Status
        if let status = detailShowModel.status, !status.isEmpty {
            detailsArray.append(DetailInfo(key: "STATUS", value: status))
        }
        
        // Runtime
        if let runtime = detailShowModel.runtime, runtime > 0 {
            detailsArray.append(DetailInfo(key: "RUNTIME", value: "\(runtime) minutes"))
        }
        
        // End date
        if let ended = detailShowModel.ended, !ended.isEmpty {
            detailsArray.append(DetailInfo(key: "ENDED", value: formatDate(ended)))
        }
        
        // Official site
        if let officialSite = detailShowModel.officialSite, !officialSite.isEmpty {
            detailsArray.append(DetailInfo(key: "OFFICIAL SITE", value: officialSite))
        }
        
        // IMDB
        if let imdb = detailShowModel.imdb, !imdb.isEmpty {
            detailsArray.append(DetailInfo(key: "IMDB", value: imdb))
        }
    }
    
    // MARK: - Summary Processing Methods
    
    private func preprocessSummary() {
        guard let summary = detailShowModel?.summary, !summary.isEmpty else { return }
        
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
    
    // MARK: - Helper Methods
    
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
    
    // MARK: - Cell Creation Methods
    
    private func createSummaryCell(at indexPath: IndexPath) -> UITableViewCell {
        let cell = infoTableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        cell.backgroundColor = .cellBackground
        cell.selectionStyle = .none
        
        var content = cell.defaultContentConfiguration()
        
        if let processedSummary = processedSummary {
            let truncated = truncateText(processedSummary, maxLength: 150)
            content.text = truncated.text
            
            if truncated.isTruncated {
                let readMoreButton = createReadMoreButton(fullText: processedSummary)
                cell.accessoryView = readMoreButton
            } else {
                cell.accessoryView = nil
            }
        } else {
            let truncated = truncateText(detailShowModel?.summary ?? "", maxLength: 150)
            content.text = truncated.text
            
            if truncated.isTruncated {
                let readMoreButton = createReadMoreButton(fullText: detailShowModel?.summary ?? "")
                cell.accessoryView = readMoreButton
            } else {
                cell.accessoryView = nil
            }
        }
        
        content.textProperties.font = UIFont.systemFont(ofSize: 16)
        content.textProperties.color = .white
        content.textProperties.numberOfLines = 0
        
        cell.contentConfiguration = content
        return cell
    }
    
    private func createDetailCell(at indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < detailsArray.count else {
            return infoTableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        }
        
        let detailInfo = detailsArray[indexPath.row]
        
        // Special handling for official site links
        if detailInfo.key == "OFFICIAL SITE" {
            return createLinkCell(with: detailInfo.value, title: detailInfo.key, at: indexPath)
        }
        
        let cell = infoTableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        cell.backgroundColor = .cellBackground
        cell.selectionStyle = .none
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
        return cell
    }
    
    private func createScheduleCell(at indexPath: IndexPath) -> UITableViewCell {
        let cell = infoTableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        cell.backgroundColor = .cellBackground
        cell.selectionStyle = .none
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
        return cell
    }
    
    private func createLinkCell(with url: String, title: String, at indexPath: IndexPath) -> UITableViewCell {
        let cell = infoTableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        
        cell.accessoryView = nil
        cell.accessoryType = .none
        
        cell.backgroundColor = .cellBackground
        cell.selectionStyle = .default
        cell.accessoryType = .disclosureIndicator
        
        var content = cell.defaultContentConfiguration()
        
        content.text = title
        content.textProperties.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        content.textProperties.color = .lightGrayText
        
        content.secondaryText = url
        content.secondaryTextProperties.font = UIFont.systemFont(ofSize: 16)
        content.secondaryTextProperties.color = .systemBlue
        content.textToSecondaryTextVerticalPadding = 4
        
        cell.contentConfiguration = content
        return cell
    }
    
    // MARK: - Read More Functionality
    
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
        summaryViewController.title = "Full Summary"
        
        let navController = UINavigationController(rootViewController: summaryViewController)
        
        summaryViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismissSummaryViewController)
        )
        
        // Create scroll view and text label
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
        
        // Setup constraints
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
    
    // MARK: - URL Handling
    
    private func openURL(_ urlString: String) {
        var finalURLString = urlString
        
        if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
            finalURLString = "https://" + urlString
        }
        
        guard let url = URL(string: finalURLString) else { return }
        
        let safariVC = SFSafariViewController(url: url)
        safariVC.preferredControlTintColor = .systemBlue
        present(safariVC, animated: true)
    }
    
    // MARK: - IBActions
    
    @IBAction func addToWatchlist(_ sender: UILongPressGestureRecognizer) {
        DataController.sharedInstance.updateWatchlist(showID: showsIDString)
        updateWatchlistButton()
        
        if DataController.sharedInstance.watchlistedShows.showsID.contains(showsIDString) {
            showAnimatedCheckmarkToast()
        }
    }
}

// MARK: - TableView DataSource & Delegate

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let infoSection = getSectionType(for: section) else { return 0 }
        
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
            return tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        }
        
        switch infoSection {
        case .summary:
            return createSummaryCell(at: indexPath)
        case .details:
            return createDetailCell(at: indexPath)
        case .schedule:
            return createScheduleCell(at: indexPath)
        }
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
        case .details, .schedule:
            return 60
        }
    }
}

// MARK: - Animated Checkmark Toast

extension DetailViewController {
    
    func showAnimatedCheckmarkToast(duration: TimeInterval = 1.5) {
        // Create toast container
        let toastContainer = UIView()
        toastContainer.layer.zPosition = 1
        toastContainer.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastContainer.layer.cornerRadius = 30
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // Create checkmark view
        let checkmarkView = CheckmarkView(frame: .zero)
        checkmarkView.translatesAutoresizingMaskIntoConstraints = false
        
        toastContainer.addSubview(checkmarkView)
        view.addSubview(toastContainer)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            toastContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            toastContainer.widthAnchor.constraint(equalToConstant: 120),
            toastContainer.heightAnchor.constraint(equalToConstant: 120),
            
            checkmarkView.centerXAnchor.constraint(equalTo: toastContainer.centerXAnchor),
            checkmarkView.centerYAnchor.constraint(equalTo: toastContainer.centerYAnchor),
            checkmarkView.widthAnchor.constraint(equalToConstant: 70),
            checkmarkView.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        // Animate appearance
        toastContainer.alpha = 0
        toastContainer.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.3, animations: {
            toastContainer.alpha = 1
            toastContainer.transform = CGAffineTransform.identity
        }) { _ in
            self.generateHapticFeedback(style: .medium)
            
            checkmarkView.animate(completion: {
                self.generateHapticFeedback(style: .heavy)
            })
            
            // Fade out animation
            UIView.animate(withDuration: 0.3, delay: duration, options: [], animations: {
                toastContainer.alpha = 0
                toastContainer.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { _ in
                toastContainer.removeFromSuperview()
            }
        }
    }
    
    private func generateHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}

// MARK: - Supporting Types and Classes

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

private struct TruncatedText {
    let text: String
    let isTruncated: Bool
}

// MARK: - CheckmarkView

class CheckmarkView: UIView {
    
    private let checkmarkLayer = CAShapeLayer()
    
    // MARK: - Initializers
    
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
        checkmarkLayer.fillColor = nil
        checkmarkLayer.strokeColor = UIColor.white.cgColor
        checkmarkLayer.lineWidth = 5
        checkmarkLayer.lineCap = .round
        checkmarkLayer.lineJoin = .round
        checkmarkLayer.strokeEnd = 0
        
        layer.addSublayer(checkmarkLayer)
        updatePath()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePath()
    }
    
    private func updatePath() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.width * 0.25, y: bounds.height * 0.5))
        path.addLine(to: CGPoint(x: bounds.width * 0.45, y: bounds.height * 0.7))
        path.addLine(to: CGPoint(x: bounds.width * 0.75, y: bounds.height * 0.3))
        checkmarkLayer.path = path.cgPath
    }
    
    // MARK: - Animation
    
    func animate(completion: (() -> Void)? = nil) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 0.5
        animation.fromValue = 0
        animation.toValue = 1
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        
        let animationDelegate = CheckmarkAnimationDelegate {
            let pulseAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
            pulseAnimation.values = [1.0, 1.2, 1.0]
            pulseAnimation.keyTimes = [0, 0.5, 1]
            pulseAnimation.duration = 0.3
            
            self.layer.add(pulseAnimation, forKey: "pulseAnimation")
            completion?()
        }
        
        animation.delegate = animationDelegate
        objc_setAssociatedObject(checkmarkLayer, UnsafeRawPointer(bitPattern: 1)!, animationDelegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        checkmarkLayer.strokeEnd = 1
        checkmarkLayer.add(animation, forKey: "checkmarkAnimation")
    }
}

// MARK: - CheckmarkAnimationDelegate

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

// MARK: - UIColor Extensions

extension UIColor {
    static let darkGrayBackground = UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1.0)
    static let lightGrayText = UIColor(red: 160/255, green: 160/255, blue: 160/255, alpha: 1.0)
    static let cellBackground = UIColor(red: 46/255, green: 46/255, blue: 46/255, alpha: 1.0)
}
